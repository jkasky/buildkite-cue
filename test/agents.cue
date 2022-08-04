package buildkite_test

import (
    "gitlab.com/jkasky/buildkite-cue/buildkite"
)

#AgentTest: {
    schema: buildkite.#agents
    expect: bool | *true
    yaml: string | *""
}

tests: {
    when_multiple_labels: #AgentTest & {
        yaml: """
            queue: default
            os: linux
            foo: bar
        """
    }
	when_queue_is_a_number: #AgentTest & {
		yaml: "queue: 1"
        expect: false
	}
    when_queue_is_a_bool: #AgentTest & {
        yaml: "queue: true"
        expect: false
    }
	when_queue_is_string: #AgentTest & {
		yaml: "queue: default"
	}
    when_empty: #AgentTest & {
        yaml: ""
    }
}
