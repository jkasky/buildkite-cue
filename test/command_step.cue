package buildkite_test

import (
	"github.com/jkasky/buildkite"
)

#CommandStepTest: {
	schema:  buildkite.#CommandStep
	isValid: bool | *true
	yaml:    string | *"---"
}

tests: {
	when_empty: #CommandStepTest & {
		isValid: false
	}
	when_no_command_or_commands: #CommandStepTest & {
		yaml: """
			    label: some command
			"""
		isValid: false
	}
	when_single_command: #CommandStepTest & {
		yaml: """
			    label: single command
			    command: echo foo
			"""
	}
	when_mutiple_commands: #CommandStepTest & {
		yaml: """
			    label: many commands
			    commands:
			        - command_1
			        - command_2
			"""
	}
	when_concurrency_present_with_group: #CommandStepTest & {
		yaml: """
			    label: concurrent command
			    command: foo
			    concurrency: 2
			    concurrency_group: group_a
			"""
	}
	when_concurrency_present_without_group: #CommandStepTest & {
		yaml: """
			    label: concurrent command
			    command: foo
			    concurrency: 2
			"""
		isValid: false
	}
	when_single_plugin: #CommandStepTest & {
		yaml: """
			    label: command with a plugin
			    command: run
			    plugins:
			        - fruit#v1.0:
			            favorite: apple
			"""
	}
	when_multiple_plugins: #CommandStepTest & {
		yaml: """
			    label: command with a plugin
			    command: run
			    plugins:
			        - fruit#v1.0:
			            favorite: apple
			        - vegetable#v123:
			            kind: broccoli
			"""
	}
	when_matrix_and_parallelism_present: #CommandStepTest & {
		yaml: """
			    label: bad mix of matrix w/ parallelism
			    command: run
			    parallelism: 3
			    matrix:
			        - neo
			        - trinity
			        - morpheus
			"""
		isValid: false
	}
	when_matrix_without_parallelism: #CommandStepTest & {
		yaml: """
			    label: good matrix
			    command: run {{matrix}}
			    matrix:
			        - neo
			        - trinity
			        - morpheus
			"""
	}
}
