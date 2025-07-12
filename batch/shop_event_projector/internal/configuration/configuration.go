package configuration

import (
	"context"
	"fmt"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/kelseyhightower/envconfig"
)

var globalConfig Config

type Config struct {
	AWSConfig   aws.Config
	Env         string `envconfig:"ENV" default:"dev"`
	ServiceName string `envconfig:"SERVICE_NAME" default:"shop-event-projector"`

	CoreDB struct {
		Host string `json:"host"`
		Port string `json:"port"`
		User string `json:"username"`
		Pass string `json:"password"`
		Name string `json:"dbname"`
	}
}

func Get() Config { return globalConfig }

func Load(ctx context.Context) (Config, error) {
	envconfig.MustProcess("", &globalConfig)
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	env := globalConfig.Env
	if err := loadAWSConf(ctx, env); err != nil {
		return globalConfig, err
	}

	if err := batchGetSecrets(
		ctx,
		globalConfig.AWSConfig,
		map[string]any{
			fmt.Sprintf("kinesis-platform-sample/%s/shop/core/rds-cluster", env): &globalConfig.CoreDB,
		},
	); err != nil {
		return Config{}, err
	}

	return globalConfig, nil
}
