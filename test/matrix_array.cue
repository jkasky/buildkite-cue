package buildkite_test

import (
    "list"

    y "encoding/yaml"

    "github.com/jkasky/buildkite-cue/buildkite"
)

#MatrixArrayTest: {
    schema: buildkite.#MatrixArray
    isValid: bool | *true
    yaml: string | *"---"
}

tests: {
    when_empty: #MatrixArrayTest & {
        isValid: false
    }
    when_single_element: #MatrixArrayTest & {
        yaml: """
            - a single item
        """
    }
    when_multible_elements: #MatrixArrayTest & {
        yaml: """
            - first item
            - second item
            - last item
        """
    }
    when_has_more_than_10_items: #MatrixArrayTest & {
        yaml: y.Marshal([for n in list.Range(0, 11, 1) {"i\(n)"}])
        isValid: false
    }
}