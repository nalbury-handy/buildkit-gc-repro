package main

import (
	randomdata "github.com/Pallinder/go-randomdata"
	log "github.com/sirupsen/logrus"
)

func main() {
	name := randomdata.SillyName()
	field := randomdata.SillyName()
	value := randomdata.SillyName()
	log.WithFields(log.Fields{
		field: value,
	}).Info(name)
}
