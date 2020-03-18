package cmd

import (
	"fmt"
	"os"
	"os/exec"

	"github.com/spf13/cobra"
)

// apiCmd represents the api command
var apiCmd = &cobra.Command{
	Use:   "api",
	Short: "Start the platform API",
	Long:  `Start the platform API.`,
	Run: func(cmd *cobra.Command, args []string) {
		// TODO once a suitable config/flags package happens remove this and just execute the package directly
		api := exec.Command("./api")
		api.Stdout = os.Stdout
		api.Stderr = os.Stderr
		api.Dir = "./api"
		if err := api.Run(); err != nil {
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
	rootCmd.AddCommand(apiCmd)
}
