# Run the script to get the environment variables of interest.
# This is a data source, so it will run at plan time.
data "external" "env" {
  program = ["${path.cwd}/scripts/envvars-to-terraform.sh"]
}

# Show the results of running the data source. This is a map of environment
# variable names to their values.
output "env" {
  value = data.external.env.result
}
