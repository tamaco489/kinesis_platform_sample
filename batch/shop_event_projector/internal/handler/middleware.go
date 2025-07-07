package handler

import (
	"context"
	"time"

	"github.com/aws/aws-lambda-go/events"
)

var timeout = 28 * time.Second

// Middleware to set timeout
//
// The purpose is to safely terminate processing by setting a shorter time than the Lambda maximum execution time of 30 seconds.
func TimeoutMiddleware(fn KinesisEventJob) KinesisEventJob {
	return func(ctx context.Context, kinesisEvent events.KinesisEvent) error {
		newCtx, cancel := context.WithTimeout(ctx, timeout)
		defer cancel()

		return fn(newCtx, kinesisEvent)
	}
}
