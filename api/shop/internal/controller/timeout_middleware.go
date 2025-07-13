package controller

import (
	"context"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

// timeoutMiddleware creates a middleware that sets a timeout for each request
func timeoutMiddleware(timeout time.Duration) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Create a context with timeout
		ctx, cancel := context.WithTimeout(c.Request.Context(), timeout)
		defer cancel()

		// Replace the request context
		c.Request = c.Request.WithContext(ctx)

		// Create a channel to signal when the request is done
		done := make(chan struct{})
		go func() {
			c.Next()
			done <- struct{}{}
		}()

		// Wait for either the request to complete or timeout
		select {
		case <-done:
			// Request completed successfully
			return
		case <-ctx.Done():
			// Timeout occurred
			c.AbortWithStatusJSON(http.StatusRequestTimeout, gin.H{
				"error": "Request timeout",
			})
			return
		}
	}
}
