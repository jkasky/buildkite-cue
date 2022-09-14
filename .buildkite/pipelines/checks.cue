import (
	"github.com/jkasky/buildkite-cue/buildkite"
)

buildkite.#Pipeline & {
	agents: queue: "default"
	steps: [
		{
			label:   "Build"
			key:     "build"
			command: "go build -o run-test cmd/run-cue-test/main.go"
			artifact_paths: ["run-test"]
		},
		{
			label:      "Test Schema"
			depends_on: "build"
			command:
                """
                buildkite-agent artifact download run-test .
                chmod 755 run-test
                ./run-test
                """
		},
	]
    notify: [
        {github_commit_status: context: "buildkite-checks"}
    ]
}
