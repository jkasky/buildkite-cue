package buildkite_test

import (
	"github.com/jkasky/buildkite"
)

#EnvTest: {
	schema:  buildkite.#Environment
	isValid: bool | *true
	yaml:    string | *"---"
}

tests: {
	when_empty: #EnvTest & {
		yaml: ""
	}
	when_value_is_map: #EnvTest & {
		yaml: """
			    a_var:
			      with_mapped: value
			"""
		isValid: false
	}
	when_values_are_expected_types: #EnvTest & {
		yaml: """
			    bool_var_0: false
			    bool_var_1: true
			    quoteed_string_var: "a string"
			    unquoted_string_var: unquoted
			    multiline_string: |
			        here we have a
			        multi line
			        string
			"""
	}
}
