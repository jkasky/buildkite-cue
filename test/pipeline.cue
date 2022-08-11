package buildkite_test

import (
    "github.com/jkasky/buildkite-cue/buildkite"
)

#PipelineTest: {
    schema: buildkite.#Pipeline
    isValid: bool | *true
    yaml: string | *"---"
}

tests: {
    when_empty: #PipelineTest & {
        isValid: false
    }
    when_unexpected_field: #PipelineTest & {
        yaml: """
            agents: default
            steps:
                - command: echo test
            invalid_pipeline_field: blah
        """
        isValid: false
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
    when_contains_invalid_step_type: #PipelineTest & {
        yaml: """
            steps:
                - label: A Valid Command Step Type
                  command: /bin/true
                - label: Unknown Step Type
                  not_a_step: will fail
        """
        isValid: false
    }
    when_contains_block_step: #PipelineTest & {
        yaml: """
            steps:
                - block: You Shall Not Pass
        """
    }
    when_contains_command_step: #PipelineTest & {
        yaml: """
            steps:
                - label: Command Step
                  command: runit
        """
    }
    when_contains_group_step: #PipelineTest & {
        yaml: """
            steps:
                - label: Group A
                  group: A
                  steps:
                    - command: run a1
                    - command: run a2
        """
    }
    when_contains_input_step: #PipelineTest & {
        yaml: """
            steps:
                - input: Info please
                  fields:
                    - text: the info
                      key: info
                      required: true
        """
    }
    when_contains_trigger_step: #PipelineTest & {
        yaml: """
            steps:
                - trigger: a-pipeline-slug
        """
    }
    when_contains_wait_step: #PipelineTest & {
        yaml: """
            steps:
                - wait
        """
    }    
}