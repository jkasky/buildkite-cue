package buildkite_test

import (
    "gitlab.com/jkasky/buildkite-cue/buildkite"
)

#BlockStepTest: {
    schema: buildkite.#BlockStep
    isValid: bool | *true
    yaml: string | *"---"
}

tests: {
    when_empty: #BlockStepTest & {
        isValid: false
    }
    when_min_fields: #BlockStepTest & {
        yaml: """
            block: blocking
        """
    }
    for s in ["failed", "passed", "running"] {
        "when_blocked_state_\(s)": #BlockStepTest & {
            yaml: """
                block: blocked in state \(s)
                blocked_state: \(s)
            """
        }
    }
    when_depends_on_single_step: #BlockStepTest & {
        yaml: """
            block: block with dependencies
            depends_on: singlestep
        """
    }
    when_depends_on_multiple_steps: #BlockStepTest & {
        yaml: """
            block: block with dependencies
            depends_on:
                - step1
                - step2
        """
    }
    when_single_field: #BlockStepTest & {
        yaml: """
            block: block with single field
            fields:
                - text: one lone field
                  key: one_field
        """
    }
    when_multiple_fields: #BlockStepTest & {
        yaml: """
            block: block with multiple fields
            fields:
                - text: text field
                  key: text_field
                - select: select field
                  key: select_field
                  options:
                    - label: a
                      value: "1"
                    - label: b
                      value: "2"
        """
    }
}