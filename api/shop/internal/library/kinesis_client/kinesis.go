package kinesis_client

import (
	"context"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/aws/retry"
	"github.com/aws/aws-sdk-go-v2/service/kinesis"
)

type KinesisClient interface {
	CreateReservationEvent(ctx context.Context, event CreateReservationEvent) (*kinesis.PutRecordOutput, error)
	CreateReservationMultiEvent(ctx context.Context, event *kinesis.PutRecordsInput) (*kinesis.PutRecordsOutput, error)
}

type KinesisWrapper struct {
	Client *kinesis.Client
}

const (
	kinesisTimeout          = 8 * time.Second // api-gw timeout is 30 seconds
	kinesisMaxRetryAttempts = 2               // Allow 2 retries (i.e., a total of 3 requests)
)

func NewKinesisClient(cfg aws.Config) *KinesisWrapper {
	client := kinesis.NewFromConfig(cfg, func(o *kinesis.Options) {
		o.Retryer = retry.AddWithMaxAttempts(retry.NewStandard(), kinesisMaxRetryAttempts)
		o.ClientLogMode = aws.LogRequestWithBody | aws.LogResponseWithBody
	})
	return &KinesisWrapper{Client: client}
}

var _ KinesisClient = (*KinesisWrapper)(nil)
