#composite
#event alert
#log alert
#metric alert
#process alert
#query alert
#rum alert
#service check
#synthetics alert
#trace-analytics alert
#slo alert
#event-v2 alert
#audit alert
#ci-pipelines alert
#ci-tests alert
#error-tracking alert

resource "datadog_monitor" "control_monitor" {
  name               = "Control Plane Monitor"
  type               = "query alert"
  message            = "{{#is_alert}} Alert: {{status}} on {{host.name}} - {{check.name}} {{/is_alert}} {{#is_recovery}} Recovery: {{status}} on {{host.name}} - {{check.name}} {{/is_recovery}} {{message}} @slack-alerts"
  escalation_message = "{{#is_alert}}Still Alerting: {{status}} on {{host.name}} - {{check.name}}{{/is_alert}}{{#is_recovery}}Recovery: {{status}} on {{host.name}} - {{check.name}}{{/is_recovery}}{{message}} @slack-alerts"

  query = "change(max(last_1h),last_5m):sum:datadog.iot_agent.running{host:control} > 0"
  #query = "datadog.agent.up.over(host:control).exclude(host:node-1,host:node-2,host:node-3).by(*).last(2).count_by_status()"

  # new_group_delay      = 300
  renotify_interval    = 360
  renotify_occurrences = 6
  renotify_statuses    = [
    "alert",
    "no data",
  ]
  priority = "1"

  # monitor_thresholds {
  #   warning  = 2
  #   critical = 4
  # }

  include_tags = true

  tags = [
    # "foo:bar",
    # "team:fooBar"
  ]
}

# change(max(last_1h),last_5m):sum:datadog.iot_agent.running{*} > 0

resource "datadog_monitor" "all_nodes_monitor" {
  name               = "All Nodes Monitor"
  type               = "query alert"
  message            = "{{#is_alert}} Alert: {{status}} on {{host.name}} - {{check.name}} {{/is_alert}} {{#is_recovery}} Recovery: {{status}} on {{host.name}} - {{check.name}} {{/is_recovery}} {{message}} @slack-alerts"
  escalation_message = "{{#is_alert}}Still Alerting: {{status}} on {{host.name}} - {{check.name}}{{/is_alert}}{{#is_recovery}}Recovery: {{status}} on {{host.name}} - {{check.name}}{{/is_recovery}}{{message}} @slack-alerts"

  query = "change(max(last_1h),last_5m):sum:datadog.iot_agent.running{*} > 0"

  # new_group_delay      = 300
  renotify_interval    = 360
  renotify_occurrences = 6
  renotify_statuses    = [
    "alert",
    "no data",
  ]
  priority = "1"

  include_tags = true

  tags = [
    # "foo:bar",
    # "team:fooBar"
  ]
}

# # Triggers if any host's clock goes out of sync with the time given by NTP. The offset threshold is configured in the Agent's `ntp.yaml` file.\n\nPlease read the [KB article](https://docs.datadoghq.com/agent/faq/network-time-protocol-ntp-offset-issues) on NTP Offset issues for more details on cause and resolution.
# resource "datadog_monitor" "ntp_check" {
#   name               = "[Auto] Clock in sync with NTP"
#   type               = "service check"
#   message            = "NTP out of sync @slack-alerts"#"{{#is_alert}} Alert: {{status}} on {{host.name}} - {{check.name}} {{/is_alert}} {{#is_recovery}} Recovery: {{status}} on {{host.name}} - {{check.name}} {{/is_recovery}} {{message}} @slack-alerts"
#   escalation_message = "NTP out of sync @slack-alerts"#"{{#is_alert}}Still Alerting: {{status}} on {{host.name}} - {{check.name}}{{/is_alert}}{{#is_recovery}}Recovery: {{status}} on {{host.name}} - {{check.name}}{{/is_recovery}}{{message}} @slack-alerts"
#
#   query = "ntp.in_sync.over(*).last(2).count_by_status()"
#
#   renotify_interval    = 360
#   renotify_occurrences = 6
#   renotify_statuses    = [
#     "alert",
#     "no data",
#   ]
#   priority = "3"
#
#   monitor_thresholds {
#     warning  = 2
#     critical = 1
#     ok = 1
#   }
#
#   tags = [
#     # "foo:bar",
#     # "team:fooBar"
#   ]
# }

resource "datadog_monitor_json" "monitor_ntp_json" {
  monitor = <<-EOF
{
	"name": "Clock in sync with NTP",
	"type": "service check",
	"query": "\"ntp.in_sync\".over(\"*\").by(\"*\").last(2).count_by_status()",
	"message": "Triggers if any host's clock goes out of sync with the time given by NTP. The offset threshold is configured in the Agent's `ntp.yaml` file.\n\nPlease read the [KB article](https://docs.datadoghq.com/agent/faq/network-time-protocol-ntp-offset-issues) on NTP Offset issues for more details on cause and resolution. @slack-alerts ",
	"tags": [],
	"options": {
    "new_host_delay": 300,
		"thresholds": {
			"critical": 1,
			"warning": 1,
			"ok": 1
		},
		"notify_audit": false,
		"notify_no_data": false,
		"renotify_interval": 0,
		"timeout_h": 0,
		"silenced": {},
		"include_tags": false
	},
	"priority": 3,
	"restricted_roles": null
}
 EOF
}

# The query in this needs to be edited
resource "datadog_monitor_json" "cpu_all_nodes_monitor" {
  monitor = <<-EOF
  {
  	"id": 112194388,
  	"name": "CPU load is very high on {{host.name}}",
  	"type": "query alert",
  	"query": "sum(last_5m):max:system.cpu.user{*} + max:system.cpu.guest{*} + max:system.cpu.system{*} > 90",
  	"message": "{{#is_alert}} To fix follow these steps\n1.SSH\n2.HTOP\n3. Check top process PID\n4. sudo kill <PID>\n{{/is_alert}} \n\n\n{{#is_recovery}} CPU load is back to normal, phew! {{/is_recovery}} \n\n@slack-alerts",
  	"tags": [],
  	"options": {
    "new_host_delay": 300,      
  		"thresholds": {
  			"critical": 90,
  			"critical_recovery": 70,
  			"warning": 75
  		},
  		"notify_audit": false,
  		"require_full_window": true,
  		"notify_no_data": true,
  		"renotify_interval": 0,
  		"locked": false,
  		"timeout_h": 0,
  		"include_tags": true,
  		"no_data_timeframe": 15,
  		"escalation_message": "",
  		"renotify_occurrences": null,
  		"renotify_statuses": null,
  		"silenced": {}
  	},
  	"priority": 2,
  	"restricted_roles": null
  }
 EOF
}

# resource "datadog_monitor_json" "cpu_all_nodes_monitor" {
#   name               = "CPU load is very high on {{host.name}}"
#   type               = "query alert"
#   message            = "{{#is_alert}} Alert: {{status}} on {{host.name}} - {{check.name}} {{/is_alert}} {{#is_recovery}} Recovery: {{status}} on {{host.name}} - {{check.name}} {{/is_recovery}} {{message}} @slack-alerts"
#   escalation_message = "{{#is_alert}}Still Alerting: {{status}} on {{host.name}} - {{check.name}}{{/is_alert}}{{#is_recovery}}Recovery: {{status}} on {{host.name}} - {{check.name}}{{/is_recovery}}{{message}} @slack-alerts"
#
#   query = "avg(last_5m):max:system.cpu.user{host:control} + max:system.cpu.user{host:node-1} > 90"
#
#   # new_group_delay      = 300
#   renotify_interval    = 360
#   renotify_occurrences = 6
#   renotify_statuses    = [
#     "alert",
#     "no data",
#   ]
#   priority = "1"
#
#   include_tags = true
#
#   tags = [
#     # "foo:bar",
#     # "team:fooBar"
#   ]
# }
