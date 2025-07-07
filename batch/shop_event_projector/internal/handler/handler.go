package handler

import (
	"context"
	"log/slog"

	"github.com/aws/aws-lambda-go/events"
	"github.com/tamaco489/kinesis_platform_sample/batch/shop_event_projector/internal/usecase"
)

// DOC: https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/with-kinesis.html
type KinesisEventJob func(ctx context.Context, kinesisEvent events.KinesisEvent) error

func ShopEventProjector(job usecase.Job) KinesisEventJob {
	return func(ctx context.Context, kinesisEvent events.KinesisEvent) error {

		slog.InfoContext(ctx, "start shop event projector by handler")

		for _, record := range kinesisEvent.Records {
			slog.InfoContext(ctx, "message", "record (all)", record)
			if err := job.ShopEventProjector(ctx); err != nil {
				return err
			}
		}

		return nil
	}
}
