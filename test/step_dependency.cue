package buildkite_test

import (
	"github.com/jkasky/buildkite"
)

#StepDependencyTest: {
	schema:  buildkite.#StepDependencies
	isValid: bool | *true
	yaml:    string | *"---"
}

tests: {
	when_explicit_empty_dependency: #StepDependencyTest & {
		yaml: """
			    null
			"""
	}
	when_single_step_key: #StepDependencyTest & {
		yaml: """
			    a-step-key
			"""
	}
	when_multiple_step_keys: #StepDependencyTest & {
		yaml: """
			    - first-step
			    - second-step
			"""
	}
	when_step_dependency: #StepDependencyTest & {
		yaml: """
			    - step: step-a
			    - step: step-b
			"""
	}
	when_step_dependency_allowing_failure: #StepDependencyTest & {
		yaml: """
			    - step: step-optional
			      allow_failure: true
			    - step: step-required
			      allow_failure: false
			"""
	}
}
