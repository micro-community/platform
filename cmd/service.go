package cmd

import (
	"fmt"
	"os"
	"os/exec"

	"github.com/spf13/cobra"
)

// serviceCmd represents the service command
var serviceCmd = &cobra.Command{
	Use:   "service",
	Short: "Start the platform service",
	Long:  `Start the platform service.`,
	Run: func(cmd *cobra.Command, args []string) {
		// TODO once a suitable config/flags package happens remove this and just execute the package directly
		service := exec.Command("./service")
		service.Stdout = os.Stdout
		service.Stderr = os.Stderr
		service.Dir = "./service"
		if err := service.Run(); err != nil {
			exitError, ok := err.(*exec.ExitError)
			if ok {
				os.Exit(exitError.ExitCode())
			}
			fmt.Fprintf(os.Stderr, "%s\n", err.Error())
			os.Exit(1)
		}
	},
}

func init() {
	rootCmd.AddCommand(serviceCmd)
}
