package buildkite_test

import (
	"github.com/jkasky/buildkite"
)

#GroupStepTest: {
	schema:  buildkite.#GroupStep
	isValid: bool | *true
	yaml:    string | *"---"
}

tests: {
	when_empty: #GroupStepTest & {
		isValid: false
	}
	when_min_fields: #GroupStepTest & {
		yaml: """
			    group: "Build Group"
			    steps:
			        - command: "echo hello"
			"""
	}
	when_group_null: #GroupStepTest & {
		yaml: """
			    group: null
			    steps:
			        - command: "echo hello"
			"""
	}
	when_with_label: #GroupStepTest & {
		yaml: """
			    group: "Test Group"
			    label: "Custom Label"
			    steps:
			        - command: "echo test"
			"""
	}
	when_with_key: #GroupStepTest & {
		yaml: """
			    group: "Key Group"
			    key: "group-key"
			    steps:
			        - command: "echo key"
			"""
	}
	when_with_dependencies: #GroupStepTest & {
		yaml: """
			    group: "Dependent Group"
			    depends_on: "previous-step"
			    steps:
			        - command: "echo depends"
			"""
	}
	when_notify_string_should_fail: #GroupStepTest & {
		isValid: false // Should fail after fix (string not allowed)
		yaml: """
			    group: "Notify Group"
			    notify: "some-string"
			    steps:
			        - command: "echo notify"
			"""
	}
	when_notify_slack_works: #GroupStepTest & {
		yaml: """
			    group: "Slack Notify Group"
			    notify:
			        - slack: "#general"
			          message: "Group completed"
			    steps:
			        - command: "echo slack"
			"""
	}
	when_notify_email_works: #GroupStepTest & {
		yaml: """
			    group: "Email Notify Group"
			    notify:
			        - email: "team@example.com"
			    steps:
			        - command: "echo email"
			"""
	}
	when_notify_github_works: #GroupStepTest & {
		yaml: """
			    group: "GitHub Notify Group"
			    notify:
			        - github_commit_status:
			            context: "group-status"
			    steps:
			        - command: "echo github"
			"""
	}
	when_notify_object_should_fail: #GroupStepTest & {
		isValid: false // Should fail with current schema (string vs object)
		yaml: """
			    group: "Object Notify Group"
			    notify:
			        slack: "#general"
			        message: "Group completed"
			    steps:
			        - command: "echo object"
			"""
	}
	when_multiple_child_steps: #GroupStepTest & {
		yaml: """
			    group: "Multi Step Group"
			    steps:
			        - command: "echo step1"
			        - wait: null
			        - command: "echo step2"
			        - input: "Continue?"
			        - trigger: "downstream-pipeline"
			"""
	}
}
