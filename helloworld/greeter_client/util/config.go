package util

import (
	"github.com/spf13/viper"
)

type Config struct {
	ClientName     string `mapstructure:"CLIENT_NAME"`
	GrpcServerIp   string `mapstructure:"GRPC_SERVER_IP"`
	GrpcServerPort uint32 `mapstructure:"GRPC_SERVER_PORT"`
}

func LoadConfig(path string) (config Config, err error) {
	viper.AddConfigPath(path)
	viper.SetConfigName("app")
	viper.SetConfigType("env")

	viper.AutomaticEnv()

	err = viper.ReadInConfig()
	if err != nil {
		return
	}

	err = viper.Unmarshal(&config)
	return
}
