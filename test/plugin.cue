package buildkite_test

import (
    "github.com/jkasky/buildkite-cue/buildkite"
)

#PluginTest: {
    schema: buildkite.#Plugin
    isValid: bool | *true
    yaml: string | *"---"
}

tests: {
    when_empty: #PluginTest & {
        isValid: false
    }
    when_no_options: #PluginTest & {
        yaml: """
            shellcheck#v1.1.2: ~
        """
    }
    when_single_option: #PluginTest & {
        yaml: """
            shellcheck#v1.1.2:
                files: scripts/*.sh
        """
    }
}