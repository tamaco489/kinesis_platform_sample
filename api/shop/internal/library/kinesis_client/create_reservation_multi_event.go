package kinesis_client

import (
	"context"

	"github.com/aws/aws-sdk-go-v2/service/kinesis"
)

func (k *KinesisWrapper) CreateReservationMultiEvent(ctx context.Context, event *kinesis.PutRecordsInput) (*kinesis.PutRecordsOutput, error) {
	return k.Client.PutRecords(ctx, event)
}
