package buildkite

import (
    "list"
    "struct"
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

#Step: #BlockStep | #CommandStep | #GroupStep | #InputStep | #TriggerStep | #WaitStep | #PluginsStep

#BlockStep: {
    block: string

    prompt?: string

    fields?: [#BlockStepField, ...#BlockStepField]

    blocked_state: "failed" | *"passed" | "running"

    branches?: string

    if?: string

    // TODO: make a type for this?
    depends_on?: string | [string, ...string]

    // TODO: possible to validate this is a unique value within the pipeline?
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

    #CommandConcurrency

    depends_on?: string | [string, ...string]

    env?: #Environment

    if?: string

    key?: string

    plugins?: [#Plugin, ...#Plugin]

    // matrix and parallelism attributes are mutally exclusive on the same step
    if matrix == _|_ {
        parallelism?: int & >1
    }

    matrix?: #MatrixArray | #MatrixSetup

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

// Concurrency, if present, most be accompanied by concurrency_group
// concurrency?: int & >0
#CommandConcurrency: *{} | {
    concurrency: int & >0
    concurrency_group: string
}

#Plugin: {
    [string]: {
        [string]: string
    } | null
}

#PluginsStep: {
    plugins: [#Plugin, ...#Plugin]
}

#MatrixArray: list.MaxItems(10) & [string, ...string]

#MatrixSetup: {
    setup: struct.MaxFields(10) & {
        [string]: list.MaxItems(10) & [string, ...string]
    }

    adjustments?: list.MaxItems(10) & [#MatrixAdjustment, ...#MatrixAdjustment]
}

#MatrixAdjustment: {
    with: {
        [string]: string
    }

    {soft_fail: bool} | {skip: true} | {}
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