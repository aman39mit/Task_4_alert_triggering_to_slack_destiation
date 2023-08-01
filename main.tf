data "newrelic_account" "acc" {
  account_id = "3933528"
}

// Create a policy to track
resource "newrelic_alert_policy" "my-slack-policy" {
  name = "my_slack_policy"
}

resource "newrelic_nrql_alert_condition" "nrql_condition" {
  account_id                     = "3933528"
  policy_id                      = newrelic_alert_policy.my-slack-policy.id
  type                           = "static"
  name                           = "foo"
  description                    = "Alert when transactions are taking too long"
  runbook_url                    = "https://www.example.com"
  enabled                        = true
  violation_time_limit_seconds   = 3600
  fill_option                    = "static"
  fill_value                     = 1.0
  aggregation_window             = 60
  aggregation_method             = "event_flow"
  aggregation_delay              = 120
  expiration_duration            = 120
  open_violation_on_expiration   = true
  close_violations_on_expiration = true
  slide_by                       = 30

  nrql {
    query = "SELECT average(cpuPercent ) FROM ProcessSample"
  }

  critical {
    operator              = "above"
    threshold             = 0.0
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }

}


// Create a reusable notification slack destination remember they are only created through and are imported into terraform

# following these steps: 
# Add an empty resource to your terraform file:
# resource "newrelic_notification_destination" "foo" {
# }
# Run import command: terraform import newrelic_notification_destination.foo <destination_id>
# Run the following command after the import successfully done and copy the information to your Slack resource: terraform state show newrelic_notification_destination.foo
# Add ignore_changes attribute on auth_token in your imported resource:
# lifecycle {
#     ignore_changes = [auth_token]
#   }

# resource "newrelic_notification_destination" "destination" {

#     lifecycle {
#         ignore_changes = [auth_token]
#     }

#     account_id = "3933528"
#     active     = true
#     id         = "f61b78cb-2ee5-4bfb-a770-95e24e37cc43"
#     name       = "Aman_workspace"
#     status     = "DEFAULT"
#     type       = "SLACK"

#     auth_token {
#         prefix = "Bearer"
#     }

#     property {
#         key = "url"
#     }
# }


// Create a notification channel to use in the workflow
resource "newrelic_notification_channel" "notification_channel" {
  account_id = "3933528"
  name = "slack-example"
  type = "SLACK"
  destination_id = "f61b78cb-2ee5-4bfb-a770-95e24e37cc43"
  product = "IINT"

  property {
    key = "channelId"
    value = "C05KJ4DE2RL"
  }

  property {
    key = "customDetailsSlack"
    value = "issue id - {{issueId}}"
  }
}

// A workflow that matches issues that include incidents triggered by the policy
resource "newrelic_workflow" "workflow-example" {
  name = "workflow-example"
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  issues_filter {
    name = "Filter-name"
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator = "EXACTLY_MATCHES"
      values = [ newrelic_alert_policy.my-slack-policy.id ]
    }
  }

  destination {
    channel_id = newrelic_notification_channel.notification_channel.id
  }
}
