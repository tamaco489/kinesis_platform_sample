package kinesis_client

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/kinesis"
	"github.com/google/uuid"
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

func NewCreateReservationEvent(
	userID string, reservedAt time.Time, products []CreateReservationProduct,
) (CreateReservationEvent, error) {
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
	eventData, err := json.Marshal(event)
	if err != nil {
		return nil, err
	}

	return k.Client.PutRecord(ctx, &kinesis.PutRecordInput{
		StreamName:   aws.String("stg-shop-event-projector"),
		Data:         eventData,
		PartitionKey: aws.String(event.EventID),
	})
}
