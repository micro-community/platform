package main

import (
	"fmt"

	"github.com/micro/platform/internal/scheduler"
)

func main() {
	// on next update bail out
	fmt.Println("Waiting for updates")
	<-scheduler.New().Update()
}
