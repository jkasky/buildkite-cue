package buildkite_test

import (
	"github.com/jkasky/buildkite"
)

#StepTextFieldTest: {
	schema:  buildkite.#StepTextField
	isValid: bool | *true
	yaml:    string | *"---"
}

#StepSelectFieldTest: {
	schema:  buildkite.#StepSelectField
	isValid: bool | *true
	yaml:    string | *"---"
}

tests: {
	when_text_field: #StepTextFieldTest & {
		yaml: """
			    text: text field
			    key: t
			"""
	}
	when_text_field_key_has_valid_chars: #StepTextFieldTest & {
		yaml: """
			    text: a valid field
			    key: alpha-0123456789/with_ALLOWED_chars
			"""
	}
	when_text_field_key_has_invalid_char: #StepTextFieldTest & {
		yaml: """
			    text: an invalid text field
			    key: key!with@invalid-chars
			"""
		isValid: false
	}
	when_text_field_key_is_not_a_string: #StepTextFieldTest & {
		yaml: """
			    text: non-string-key field
			    key: 42
			"""
		isValid: false
	}
	when_select_field: #StepSelectFieldTest & {
		yaml: """
			    select: select field
			    key: s
			    options:
			        - label: a
			          value: foo
			        - label: b
			          value: bar
			"""
	}
	when_select_field_missing_options: #StepSelectFieldTest & {
		yaml: """
			    select: select field
			    key: s
			"""
		isValid: false
	}
	when_select_field_has_invalid_option: #StepSelectFieldTest & {
		yaml: """
			    select: select field
			    key: s
			    options:
			        - label: ok
			        - badfield: notok
			"""
		isValid: false
	}
}
