package kinesis_client

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/kinesis"
	"github.com/google/uuid"
	"github.com/tamaco489/kinesis_platform_sample/api/shop/internal/configuration"
)

type CreateReservationEvent struct {
	EventType     EventType                  `json:"event_type"`
	EventID       string                     `json:"event_id"`
	UserID        string                     `json:"user_id"`
	ReservationID string                     `json:"reservation_id"`
	ReservedAt    time.Time                  `json:"reserved_at"`
	Products      []CreateReservationProduct `json:"products"`
}

type CreateReservationProduct struct {
	ProductID uint32 `json:"product_id"`
	Quantity  uint32 `json:"quantity"`
	UnitPrice uint32 `json:"unit_price"`
}

func NewCreateReservationEvent(userID string, reservedAt time.Time, products []CreateReservationProduct) (CreateReservationEvent, error) {
	reservationID, err := uuid.NewV7()
	if err != nil {
		return CreateReservationEvent{}, fmt.Errorf("failed to new uuid for reservation: %w", err)
	}

	event := CreateReservationEvent{
		EventType:     EventTypeCreateReservation,
		EventID:       uuid.New().String(),
		UserID:        userID,
		ReservationID: reservationID.String(),
		ReservedAt:    reservedAt,
		Products:      products,
	}

	return event, nil
}

func (k *KinesisWrapper) CreateReservationEvent(ctx context.Context, event CreateReservationEvent) (*kinesis.PutRecordOutput, error) {
	timeoutCtx, cancel := context.WithTimeout(ctx, kinesisTimeout)
	defer cancel()

	eventData, err := json.Marshal(event)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal event data: %w", err)
	}

	result, err := k.Client.PutRecord(timeoutCtx, &kinesis.PutRecordInput{
		StreamName:   aws.String(configuration.Get().KinesisDataStream.ShopEvent),
		PartitionKey: aws.String(event.EventID),
		Data:         eventData,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to put record to kinesis: %w", err)
	}

	return result, nil
}
