package kinesis_client

import (
	"context"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/aws/retry"
	"github.com/aws/aws-sdk-go-v2/service/kinesis"
	"github.com/tamaco489/kinesis_platform_sample/api/shop/internal/configuration"
)

type KinesisClient interface {
	CreateReservationEvent(ctx context.Context, event CreateReservationEvent) (*kinesis.PutRecordOutput, error)
	CreateReservationMultiEvent(ctx context.Context, event *kinesis.PutRecordsInput) (*kinesis.PutRecordsOutput, error)
}

type KinesisWrapper struct {
	Client *kinesis.Client
}

const (
	kinesisTimeout          = 8 * time.Second        // api-gw timeout is 30 seconds
	kinesisMaxRetryAttempts = 2                      // Allow 2 retries (i.e., a total of 3 requests)
	kinesisBaseDelay        = 100 * time.Millisecond // 100ms
	kinesisMaxDelay         = 2 * time.Second        // 2 seconds
)

// NewKinesisClient creates a new Kinesis client with environment-specific configuration.
//
// The client is configured with custom retry logic and logging based on the environment:
//   - dev: No retry configuration, basic logging
//   - stg: Custom retry with exponential backoff, detailed request/response logging
//   - prd: Custom retry with exponential backoff, no logging for performance
func NewKinesisClient(cfg aws.Config) *KinesisWrapper {
	var opt kinesis.Options
	switch configuration.Get().API.Env {
	case "dev":
		// do nothing

	case "stg":
		opt = kinesis.Options{
			Retryer:       customRetryer(),
			ClientLogMode: aws.LogRequestWithBody | aws.LogResponseWithBody,
		}
	case "prd":
		opt = kinesis.Options{
			Retryer:       customRetryer(),
			ClientLogMode: 0, // No log output
		}
	default:
		// do nothing
	}

	client := kinesis.NewFromConfig(cfg, func(o *kinesis.Options) {
		o.Retryer = opt.Retryer
		o.ClientLogMode = opt.ClientLogMode
	})

	return &KinesisWrapper{Client: client}
}

// customRetryer creates a custom retryer with exponential backoff for Kinesis operations.
//
// Configuration:
//   - Max attempts: 3 total requests (initial + 2 retries)
//   - Base delay: 100ms with exponential backoff
//   - Max delay: 2 seconds to prevent excessive delays
//   - Jitter: Added to prevent thundering herd problems
//
// Retry behavior:
//   - 1st retry: ~100ms delay
//   - 2nd retry: ~200ms delay (capped at 2 seconds)
//   - Automatic retry on network errors, timeouts, and throttling
func customRetryer() aws.Retryer {
	retryer := retry.NewStandard(func(o *retry.StandardOptions) {
		o.MaxAttempts = kinesisMaxRetryAttempts + 1
		o.Backoff = retry.NewExponentialJitterBackoff(kinesisBaseDelay)
		o.MaxBackoff = kinesisMaxDelay
	})
	return retryer
}

var _ KinesisClient = (*KinesisWrapper)(nil)
