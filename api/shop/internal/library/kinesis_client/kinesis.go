package kinesis_client

import (
	"context"

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

const kinesisMaxRetryAttempts = 3

func NewKinesisClient(cfg aws.Config) *KinesisWrapper {
	client := kinesis.NewFromConfig(cfg, func(o *kinesis.Options) {
		o.Retryer = retry.AddWithMaxAttempts(retry.NewStandard(), kinesisMaxRetryAttempts)
	})
	return &KinesisWrapper{Client: client}
}

var _ KinesisClient = (*KinesisWrapper)(nil)
