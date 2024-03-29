package tests

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestDeployBaseStack(t *testing.T) {
	var tfOptions = terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
	})

	terraform.Validate(t, tfOptions)
	terraform.Init(t, tfOptions)
	terraform.Apply(t, tfOptions)
}
