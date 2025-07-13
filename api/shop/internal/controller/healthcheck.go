package controller

import (
	"github.com/gin-gonic/gin"
	"github.com/tamaco489/kinesis_platform_sample/api/shop/internal/gen"
)

func (c *Controllers) Healthcheck(ctx *gin.Context, request gen.HealthcheckRequestObject) (gen.HealthcheckResponseObject, error) {

	// time.Sleep(10 * time.Second)

	return gen.Healthcheck200JSONResponse{
		Message: "OK",
	}, nil
}
