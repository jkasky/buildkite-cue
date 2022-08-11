package buildkite_test

import (
    "github.com/jkasky/buildkite-cue/buildkite"
)

#BlockStepFieldTest: {
    schema: buildkite.#BlockStepField
    isValid: bool | *true
    yaml: string | *"---"
}

tests: {
    when_text_field: #BlockStepFieldTest & {
        yaml: """
            text: text field
            key: t
        """
    }
    when_select_field: #BlockStepFieldTest & {
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
    when_select_field_missing_options: #BlockStepFieldTest & {
        yaml: """
            select: select field
            key: s
        """
        isValid: false
    }
    when_select_field_has_invalid_option: #BlockStepFieldTest & {
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