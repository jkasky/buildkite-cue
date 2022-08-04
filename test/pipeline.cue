package buildkite_test

import (
    "gitlab.com/jkasky/buildkite-cue/buildkite"
)

#PipelineTest: {
    schema: buildkite.#pipeline
    expect: bool | *true
    yaml: string | *"---"
}

tests: {
    when_empty: #PipelineTest & {
        expect: false
    }
    when_unexpected_field: #PipelineTest & {
        yaml: """
            agents: default
            steps:
                - command: echo test
            invalid_pipeline_field: blah
        """
        expect: false
    }
    when_single_step: #PipelineTest & {
        yaml: """
            steps:
                - label: A Single Step
                  command: echo single step
        """
    }
    when_multiple_steps: #PipelineTest & {
        yaml: """
            steps:
                - label: First Step
                  command: /bin/true
                - label: Second Step
                  command: /bin/false
        """
    }
}