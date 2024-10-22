terraform {
  backend "s3" {
    bucket         = "terraform-state-storage-silo" # S3 bucket name (make sure this name is globally unique)
    key            = "terraform.tfstate"            # File path for storing state
    region         = "ap-south-1"                   # AWS region
    encrypt        = true                           # Enable server-side encryption
    dynamodb_table = "terraform-lock-silo"          # DynamoDB table for state locking (create manually in the console)
  }
  required_providers {
    newrelic = {
      source = "newrelic/newrelic"
    }
  }
}
provider "aws" {
  region = var.region
}
data "aws_ssm_parameter" "new_relic_user_key" {
  name = "/new-relic/new_relic_user_key"
}
provider "newrelic" {
  account_id = var.new_relic_account_id
  api_key    = data.aws_ssm_parameter.new_relic_user_key.value
  region     = var.new_relic_region
}
resource "newrelic_notification_channel" "slack_channel_1" {
  account_id     = var.new_relic_account_id
  name           = "alerts-fiqore"
  type           = "SLACK"
  destination_id = var.new_relic_destination_id
  product        = "IINT"
  property {
    key           = "channelId"
    value         = var.new_relic_channel_id
    display_value = "alerts-fiqore"
  }
  property {
    key = "customDetailsSlack"
    value = trimspace(<<-EOT
    Error Message: {{ accumulations.tag.error.group.message }}
    EOT
    )
  }
  property {
    key   = "sendUpdatesToChannel"
    value = "true"
  }
}
resource "newrelic_alert_policy" "policy" {
  account_id          = var.new_relic_account_id
  name                = "react-native-policy"
  incident_preference = "PER_CONDITION_AND_TARGET"
}
resource "newrelic_nrql_alert_condition" "condition_1" {
  account_id         = var.new_relic_account_id
  policy_id          = newrelic_alert_policy.policy.id
  name               = "react-native- unique error test"
  type               = "static"
  aggregation_window = 30
  aggregation_method = "EVENT_TIMER"
  aggregation_timer  = 30

  nrql {
    query = "SELECT sum(newrelic.error.group.occurrences) as count FROM Metric WHERE (metricName = 'newrelic.error.group.occurrences') FACET `error.group.name`, `error.group.message`, `entity.name`"
  }
  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 60
    threshold_occurrences = "AT_LEAST_ONCE"
  }

}
resource "newrelic_nrql_alert_condition" "condition_2" {
  account_id         = var.new_relic_account_id
  policy_id          = newrelic_alert_policy.policy.id
  name               = "react-native- repetitive error test"
  type               = "static"
  aggregation_window = 30
  aggregation_method = "EVENT_TIMER"
  aggregation_timer  = 30
  nrql {
    query = "SELECT sum(newrelic.error.group.occurrences) as count FROM Metric WHERE (metricName = 'newrelic.error.group.occurrences') FACET `error.group.name`, `error.group.message`, `entity.name`"
  }
  critical {
    operator              = "above"
    threshold             = 2
    threshold_duration    = 60
    threshold_occurrences = "AT_LEAST_ONCE"
  }
}
resource "newrelic_workflow" "workflow" {
  account_id            = var.new_relic_account_id
  name                  = "Policy for Error Log test : slack-policy-test"
  enabled               = true
  muting_rules_handling = "DONT_NOTIFY_FULLY_MUTED_ISSUES"
  issues_filter {
    name = "workflow_filter"
    type = "FILTER"
    predicate {
      attribute = "labels.policyIds"
      operator  = "EXACTLY_MATCHES"
      values    = [newrelic_alert_policy.policy.id]
    }
  }
  destination {
    channel_id              = newrelic_notification_channel.slack_channel_1.id
    notification_triggers   = ["ACKNOWLEDGED", "ACTIVATED", "CLOSED"]
    update_original_message = true
  }
}
