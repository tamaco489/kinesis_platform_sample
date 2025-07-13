package main

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/tamaco489/kinesis_platform_sample/api/shop/internal/configuration"
	"github.com/tamaco489/kinesis_platform_sample/api/shop/internal/controller"
)

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	cnf, err := configuration.Load(ctx)
	if err != nil {
		slog.Error("Failed to read configuration", "error", err)
		panic(err)
	}

	server, err := controller.NewShopAPIServer(cnf)
	if err != nil {
		panic(err)
	}

	go func() {
		if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			slog.ErrorContext(ctx, "failed to listen and serve", "error", err)
		}
	}()

	// Create a channel to receive OS signals and wait for a signal
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	// After receiving a signal, create a context for shutdown and perform the shutdown within 500 milliseconds
	shutdownCtx, shutdownCancel := context.WithTimeout(context.Background(), 500*time.Millisecond)
	defer shutdownCancel()

	if err = server.Shutdown(shutdownCtx); err != nil {
		slog.ErrorContext(shutdownCtx, "shutdown server...", slog.String("error", err.Error()))
	}

	<-ctx.Done()
}
