import "gitlab.com/jkasky/buildkite-cue/buildkite"

buildkite.#pipeline & {

	agents: os: "linux"

	env: {
		FOO:      "bar"
		BAR:      "foo"
		abc_bar:  "YAY"
		a_bool:   true
		a_number: 22
		a_float:  4.2
	}

	steps: [
		{
			label: "step-1"
			commands: [
				"echo running step 1a",
				"echo runners step 1b",
				"13.0",
			]
		},
		{
			label:             "command-step"
			command:           "run single command"
			concurrency:       3
			concurrency_group: "foo/bar"
			retry: manual: {
				allowed:        false
				permit_on_pass: false
				reason:         "oh no you don't"
			}
		},
		{
			wait: null
			if:   "build.branch == \"main\""
		},
        {
            block: "stop"
            if: "true == false"
            fields: [
                {text: "text", key: "text-key", required: false}
            ]
        }
	]
}
