package main

import (
	"context"
	"log/slog"
	"os"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/tamaco489/kinesis_platform_sample/batch/shop_event_projector/internal/configuration"
	"github.com/tamaco489/kinesis_platform_sample/batch/shop_event_projector/internal/handler"
	"github.com/tamaco489/kinesis_platform_sample/batch/shop_event_projector/internal/library/logging"
	"github.com/tamaco489/kinesis_platform_sample/batch/shop_event_projector/internal/usecase"
)

func main() {
	h := logging.NewLambdaSlogHandler(
		slog.NewJSONHandler(
			os.Stdout,
			&slog.HandlerOptions{AddSource: true},
		),
	)
	slog.SetDefault(slog.New(h))

	ctx := context.Background()
	cfg, err := configuration.Load(ctx)
	if err != nil {
		panic(err)
	}

	job, err := usecase.NewJob(cfg)
	if err != nil {
		panic(err)
	}

	lambda.Start(handler.TimeoutMiddleware(
		handler.ShopEventProjector(*job),
	),
	)
}
