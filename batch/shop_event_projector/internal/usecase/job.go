package usecase

import (
	"context"

	"github.com/tamaco489/kinesis_platform_sample/batch/shop_event_projector/internal/configuration"
)

type Jobber interface {
	ShopEventProjector(ctx context.Context) error
}

var _ Jobber = (*Job)(nil)

type Job struct{}

func NewJob(cfg configuration.Config) (*Job, error) {
	return &Job{}, nil
}
