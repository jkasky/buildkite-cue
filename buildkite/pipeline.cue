package buildkite

import (
    "list"
)


#Pipeline: {
    agents: #Agents
    
    env?: #Environment
    
    steps: [#Step, ...#Step]
}

#Agents: {
    queue: string | *"default"
    [string]: string
}

#Environment: {
    [string]: bool | number | string
}

#Step: #BlockStep | #CommandStep | #GroupStep | #InputStep | #TriggerStep | #WaitStep

#BlockStep: {
    block: string

    prompt?: string

    fields?: [#BlockStepField, ...#BlockStepField]

    blocked_state: "failed" | *"passed" | "running"

    branches?: string

    if?: string

    // TODO: make a type for this?
    depends_on?: string | [string, ...string]

    // TODO: possible to validate this is unique?
    key?: string

    allow_dependency_failure: bool | *false
}

#BlockStepField: #StepTextField | #StepSelectField

#StepTextField: {
    text: string

    // TODO: make type for key that validates pattern
    key: string

    required: bool | *true
    
    default?: string
    
    hint?: string
}

#StepSelectField: {
    select: string

    key: string

    options: [#StepSelectFieldOption, ...#StepSelectFieldOption]
}

#StepSelectFieldOption: {
    label: string
    value: string
}

#CommandStep: {
    label?: string
    #CommandStepField
    #CommandStepOptions
}

#CommandStepField: {command: string} | {commands: [string, ...string]}

// https://buildkite.com/docs/pipelines/command-step#command-step-attributes
#CommandStepOptions: {
    agents?: #Agents
    
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

    env?: #Environment

    if?: string

    key?: string

    // TOOD: implement matrix
    // https://buildkite.com/docs/pipelines/command-step#command-step-attributes
    // https://buildkite.com/docs/pipelines/command-step#matrix-attributes

    parallelism?: int & >1

    // TODO: implement plugins
    // https://buildkite.com/docs/pipelines/command-step#command-step-attributes

    retry?: this={
        automatic?: bool | 
            #RetryAutomaticCondition |
            [#RetryAutomaticCondition, ...#RetryAutomaticCondition]
        manual?: bool | #RetryManualAttributes

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

#RetryAutomaticCondition: {
    exit_status: "*" | int & != 0
    limit: int & >0 & <= 10
}

#RetryManualAttributes: this={
    allowed: bool | *true
    permit_on_pass?: bool
    if !this.allowed {
        reason: string
    }
}

#GroupStep: {
    group: string | *null

    allow_dependency_failure: bool | *false

    depends_on?: [string, ...string]

    key?: string

    label?: string

    notify?: string

    steps: [#GroupStepMemberStep, ...#GroupStepMemberStep]
}

#GroupStepMemberStep: #CommandStep | #TriggerStep | #WaitStep

#InputStep: {
    input: string
    
    prompt?: string

    fields: [#InputStepField, ...#InputStepField]

    branches?: string

    if?: string

    // TODO: make a type for this?
    depends_on?: string | [string, ...string]

    allow_dependency_failure: bool | *false
}

#InputStepField: #StepTextField | #StepSelectField

#TriggerStep: {
    trigger: #SlugString

    build?: #BuildAttributes

    label?: string

    async: bool | *false

    branches?: string

    if?: string

    depends_on?: string | [string, ...string]

    allow_dependency_failure: bool | *false

    skip?: bool | string
}

#BuildAttributes: {
    message?: string

    commit?: string

    branch?: string

    meta_data?: #Environment 

    env?: #Environment
}

#SlugString: string & =~"^[a-zA-Z0-9-]+$"

#WaitStep: "wait" | {
    wait: null

    continue_on_failure?: bool

    if?: string

    // TODO: see if this can validate whether the strings match named steps
    depends_on?: [string, ...string]

    allow_dependency_failure: bool | *false
}