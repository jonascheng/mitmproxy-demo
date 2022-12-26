package util

import (
	"github.com/spf13/viper"
)

type Config struct {
	ServerIp         string `mapstructure:"SERVER_IP"`
	ServerListenPort uint32 `mapstructure:"SERVER_LISTEN_PORT"`
	GrpcListenPort   uint32 `mapstructure:"GRPC_LISTEN_PORT"`
	HttpListenPort   uint32 `mapstructure:"HTTP_LISTEN_PORT"`
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
