# Configure terraform
terraform {
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
    }
  }
}

# Configure the New Relic provider
provider "newrelic" {
  account_id = "3933528"
  api_key ="NRAK-G9JMX1EYJEC7JLFP77V0XFJJ1RA"    # Usually prefixed with 'NRAK'
  region = "US"                    # Valid regions are US and EU
}