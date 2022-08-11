package buildkite_test

import (
    "list"

    y "encoding/yaml"

    "github.com/jkasky/buildkite-cue/buildkite"
)

#MatrixSetupTest    : {
    schema: buildkite.#MatrixSetup
    isValid: bool | *true
    yaml: string | *"---"
}

tests: {
    when_empty: #MatrixSetupTest & {
        isValid: false
    }
    when_no_adjustments: #MatrixSetupTest & {
        yaml: """
            setup:
                os:
                    - linux
                    - macos
                    - windows
                arch:
                    - arm64
                    - amd64
        """
    }
    when_more_than_10_dimensions: #MatrixSetupTest & {
        #data: {
            setup: {
                for n in list.Range(0, 11, 1) {
                    "d\(n)": ["item \(n)"]
                }
            }
        }
        yaml: y.Marshal(#data)
        isValid: false
    }
    when_has_adjustment_with_soft_fail: #MatrixSetupTest & {
        yaml: """
            setup:
                fruit:
                    - apple
                    - banana
                size:
                    - small
                    - medium
            adjustments:
                - with:
                    fruit: banana
                    size: small
                  soft_fail: true
        """
    }
    when_has_adjustment_with_skip: #MatrixSetupTest & {
        yaml: """
            setup:
                fruit:
                    - apple
                    - banana
                size:
                    - small
                    - medium
            adjustments:
                - with:
                    fruit: apple
                    size: medium
                  skip: true
        """
    }
    when_has_more_than_10_adjustments: #MatrixSetupTest & {
        #data: {
            setup: {
                shape: ["square", "triangle"]
                color: ["green", "blue"]
            }
            adjustments: [
                for n in list.Range(0, 11, 1) {
                    with: {
                        a: "\(n)"
                    }
                    skip: true
                }
            ]
        }
        yaml: y.Marshal(#data)
        isValid: false
    }
}