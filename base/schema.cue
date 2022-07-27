package base

import (
    "list"
)


#pipeline: {
    agents: #agents
    
    env?: #env
    
    steps: [
        #step_type,
        ...#step_type
    ]
}

#agents: {
    queue: string | *"default"
    [string]: string
}

#env: {
    [string]: bool | number | string
}

#step_type: #block_step | #command_step | #group_step | #input_step | #trigger_step | #wait_step

#block_step: {
    block: string

    prompt?: string

    fields?: [#block_step_field, ...#block_step_field]

    blocked_state: "failed" | *"passed" | "running"

    branches?: string

    "if"?: string

    // TODO: make a type for this?
    depends_on?: string | [string, ...string]

    // TODO: possible to validate this is unique?
    key?: string

    allow_dependency_failure: bool | *false
}

#block_step_field: #text_field | #select_field

#text_field: {
    text: string

    // TODO: make type for key that validates pattern
    key: string

    required: bool | *true
    
    default?: string
    
    hint?: string
}

#select_field: {
    select: string

    key: string

    options: [#select_option, ...#select_option]
}

#select_option: {
    label: string
    value: string
}

#command_step: {
    label: string
    #command_field
    #command_opts
}

#command_field: {command: string} | {commands: [string, ...string]}

// https://buildkite.com/docs/pipelines/command-step#command-step-attributes
#command_opts: {
    agents?: #agents
    
    allow_dependency_failure: bool | *false

    // TODO: add pattern constraint for paths?
    artifact_paths?: string | [string, ...string]

    branches?: string

    cancel_on_build_failing: bool | *false

    // Concurrency, if present, most be accompanied by concurrency_group
    concurrency?: int & >0
    if concurrency != _|_ {
        concurrency_group: string
    }

    depends_on?: [string, ...string]

    env?: #env

    "if"?: string

    key?: string

    // matrix
    // https://buildkite.com/docs/pipelines/command-step#command-step-attributes
    // https://buildkite.com/docs/pipelines/command-step#matrix-attributes

    parallelism?: int & >1

    // plugins
    // https://buildkite.com/docs/pipelines/command-step#command-step-attributes

    retry?: this={
        automatic?: bool | 
            #retry_automatic_condition |
            [#retry_automatic_condition, ...#retry_automatic_condition]
        manual?: bool | #retry_manual_attributes

        // Retry must have automatic and/or manual fields.
        #AnyOf: true & list.MinItems([
            for label, _ in this if list.Contains(["automatic", "manual"], label)
                {label}
        ], 1)
    }

    skip?: bool | string

    soft_fail?: true | int | [int, ...int]

    timeout_in_minutes?: int & >=0

    priority: int | *0
}

#retry_automatic_condition: {
    exit_status: "*" | int & != 0
    limit: int & >0 & <= 10
}

#retry_manual_attributes: this={
    allowed: bool | *true
    permit_on_pass?: bool
    if !this.allowed {
        reason: string
    }
}

#group_step: {
    group: string

    allow_dependency_failure: bool | *false

    depends_on: [string, ...string]

    key?: string

    label?: string

    notify?: string

    steps: [#group_step_type, ...#group_step_type]
}

#group_step_type: #command_step | #trigger_step | #wait_step

#input_step: {
    input: string
    
    prompt?: string

    fields: [#input_step_field, ...#input_step_field]

    branches?: string

    "if"?: string

    // TODO: make a type for this?
    depends_on?: string | [string, ...string]

    allow_dependency_failure: bool | *false
}

#input_step_field: #text_field | #select_field

#trigger_step: {
    trigger: #slug

    build?: #build_attributes

    label: string

    async: bool | false

    branches?: string

    "if"?: string

    depends_on?: string | [string, ...string]

    allow_dependency_failure: bool | *false

    skip: bool | string
}

#build_attributes: {
    message?: string

    commit?: string

    branch?: string

    meta_data?: #env 

    env?: #env
}

#slug: string & =~"^[a-zA-Z0-9-]+$"

#wait_step: "wait" | {
    wait: null

    continue_on_failure?: bool

    "if"?: string

    // TODO: see if this can validate whether the strings match named steps
    depends_on?: [string, ...string]

    allow_dependency_failure: bool | *false
}