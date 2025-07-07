package usecase

import (
	"context"
	"log/slog"
)

func (j *Job) ShopEventProjector(ctx context.Context) error {

	slog.InfoContext(ctx, "start shop event projector...")

	// todo: ここで KDS event 取得して DB に反映

	return nil
}
