package usecase

import (
	"database/sql"
	"fmt"
	"log/slog"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/tamaco489/kinesis_platform_sample/api/shop/internal/configuration"
	"github.com/tamaco489/kinesis_platform_sample/api/shop/internal/gen"
	"github.com/tamaco489/kinesis_platform_sample/api/shop/internal/library/kinesis_client"

	repository_gen_sqlc "github.com/tamaco489/kinesis_platform_sample/api/shop/internal/repository/gen_sqlc"
)

func (ru reservationUseCase) CreateReservation(ctx *gin.Context, uid string, request gen.CreateReservationRequestObject) (gen.CreateReservationResponseObject, error) {

	// Get product information: Product ID, Product Price, Discount Rate, Stock Quantity
	ids := make([]uint32, len(*request.Body))

	// Create a map of product_id and quantity.
	productIDQuantityMap := make(map[uint32]uint32)
	for i, p := range *request.Body {
		ids[i] = p.ProductId
		productIDQuantityMap[p.ProductId] = p.Quantity
	}

	// NOTE: In the stg environment only, return mock values until RDS setup is complete.
	var products []repository_gen_sqlc.GetProductsByIDsRow
	var err error
	switch configuration.Get().API.Env {
	case "dev":
		products, err = ru.queries.GetProductsByIDs(ctx, ru.db, ids)
		if err != nil {
			return gen.CreateReservation500Response{}, fmt.Errorf("failed to get products: %w", err)
		}

	case "stg":
		products = []repository_gen_sqlc.GetProductsByIDsRow{
			{
				ProductID:            10001001,
				ProductStockQuantity: 10000,
				ProductPrice:         0,
				DiscountRate:         sql.NullInt32{Valid: false},
			},
			{
				ProductID:            10001003,
				ProductStockQuantity: 2000,
				ProductPrice:         3000,
				DiscountRate:         sql.NullInt32{Int32: 20, Valid: true},
			},
			{
				ProductID:            10001009,
				ProductStockQuantity: 10000,
				ProductPrice:         300,
				DiscountRate:         sql.NullInt32{Valid: false},
			},
			{
				ProductID:            10001014,
				ProductStockQuantity: 5000,
				ProductPrice:         1000,
				DiscountRate:         sql.NullInt32{Int32: 15, Valid: true},
			},
		}
	}

	// Validate product availability
	if err := ru.validateProductAvailability(ctx, products, productIDQuantityMap); err != nil {
		return gen.CreateReservation400Response{}, nil
	}

	// Calculate the discounted price of the product.
	discountedPriceMap := ru.calculateDiscountedPrices(products)

	reservedAt := time.Now()

	reservationProducts := make([]kinesis_client.CreateReservationProduct, len(products))
	for i, p := range products {
		reservationProducts[i] = kinesis_client.CreateReservationProduct{
			ProductID: p.ProductID,
			Quantity:  productIDQuantityMap[p.ProductID],
			UnitPrice: discountedPriceMap[p.ProductID],
		}
	}

	event, err := kinesis_client.NewCreateReservationEvent(uid, reservedAt, reservationProducts)
	if err != nil {
		return gen.CreateReservation500Response{}, fmt.Errorf("failed to new create reservation event: %w", err)
	}

	if configuration.Get().API.Env != "dev" {
		res, err := ru.kinesisClient.CreateReservationEvent(ctx, event)
		if err != nil {
			return gen.CreateReservation500Response{}, fmt.Errorf("failed to send reservation event to kinesis: %w", err)
		}
		slog.InfoContext(ctx, "reservation event sent to kinesis successfully", slog.String("reservation_id", event.ReservationID), slog.String("user_id", uid), slog.Any("response", res))
	}

	return gen.CreateReservation201JSONResponse{
		ReservationId: event.ReservationID,
	}, nil
}

// validateProductAvailability: Validate product stock quantities. Check product existence, stock quantity, and order quantity.
func (ru reservationUseCase) validateProductAvailability(ctx *gin.Context, products []repository_gen_sqlc.GetProductsByIDsRow, productIDQuantityMap map[uint32]uint32) error {
	// If no product is found, return 404.
	if len(products) == 0 {
		slog.ErrorContext(ctx, "product not found")
		return fmt.Errorf("product not found")
	}

	for _, p := range products {
		// If the stock quantity is 0
		if p.ProductStockQuantity == 0 {
			return fmt.Errorf("product out of stock: product_id=%d, product_stock_quantity=%d", p.ProductID, p.ProductStockQuantity)
		}
		// If the requested quantity exceeds the stock quantity
		if p.ProductStockQuantity < productIDQuantityMap[p.ProductID] {
			return fmt.Errorf("product stock quantity is less than requested quantity: product_id=%d, product_stock_quantity=%d, requested_quantity=%d", p.ProductID, p.ProductStockQuantity, productIDQuantityMap[p.ProductID])
		}
	}

	return nil
}

// calculateDiscountedPrices: Calculate discounted prices for products based on the discount rate. If no discount rate is set, use the regular product price.
func (ru reservationUseCase) calculateDiscountedPrices(products []repository_gen_sqlc.GetProductsByIDsRow) map[uint32]uint32 {
	// If the discount rate is specified for the product, change the price to the discounted price. If the discount rate is not specified, use the product price as is.
	discountedPrice := make(map[uint32]uint32)
	for _, p := range products {
		// If the discount rate is not specified, use the product price as is.
		if !p.DiscountRate.Valid {
			discountedPrice[p.ProductID] = uint32(p.ProductPrice)
			continue
		}
		// If the discount rate is specified, change the price to the discounted price.
		discountedPrice[p.ProductID] = uint32(p.ProductPrice * (100 - p.DiscountRate.Int32) / 100)
	}

	return discountedPrice
}
