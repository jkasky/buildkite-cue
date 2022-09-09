package buildkite

import (
    "list"
    "struct"
)


#Pipeline: {
    agents?: #Agents

    env?: #Environment

    steps: [#Step, ...#Step]

    notify?: #Notify
}

#Agents: {
    queue?: string | *"default"
    [string]: string
}

#Environment: {
    [string]: bool | number | string
}

#Step: #BlockStep | #CommandStep | #GroupStep | #InputStep | #TriggerStep | #WaitStep | #PluginsStep

#StepKey: string

#StepDependency: {
    step: #StepKey
    allow_failure?: bool
}

#StepDependencies: #StepKey | [#StepKey, ...#StepKey] | [#StepDependency, ...#StepDependency] | null

#BlockStep: {
    block: string

    prompt?: string

    fields?: [#BlockStepField, ...#BlockStepField]

    blocked_state: "failed" | *"passed" | "running"

    branches?: string

    if?: string

    depends_on?: #StepDependencies

    // TODO: possible to validate this is a unique value within the pipeline?
    key?: string

    allow_dependency_failure: bool | *false
}

#BlockStepField: #StepTextField | #StepSelectField

#MetaDataKey: string & =~"^(?:[[:alnum:]]|-|_|/)+$"

#StepTextField: {
    text: string

    key: #MetaDataKey

    required: bool | *true

    default?: string

    hint?: string
}

#StepSelectField: {
    select: string

    key: #MetaDataKey

    required: bool | *true

    hint?: string

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

    allow_dependency_failure?: bool | *false

    // TODO: add pattern constraint for paths?
    artifact_paths?: string | [string, ...string]

    branches?: string

    cancel_on_build_failing?: bool | *false

    #CommandConcurrency

    depends_on?: #StepDependencies

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

    priority?: int | *0

    notify?: #Notify
}

// Concurrency, if present, most be accompanied by concurrency_group
// concurrency?: int & >0
#CommandConcurrency: *{} | {
    concurrency: int & >0
    concurrency_group: string
}

// Allow any structure under plugins, which accept any variety of inputs or null.
#Plugin: {
    [string]: [...] | {...} | null
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

    allow_dependency_failure?: bool | *false

    depends_on?: #StepDependencies

    key?: string

    label?: string

    notify?: string

    steps: [#GroupStepMemberStep, ...#GroupStepMemberStep]
}

#GroupStepMemberStep: #CommandStep | #InputStep | #TriggerStep | #WaitStep

#InputStep: {
    input: string

    prompt?: string

    fields?: [#InputStepField, ...#InputStepField]

    branches?: string

    if?: string

    key?: string

    depends_on?: #StepDependencies

    allow_dependency_failure?: bool | *false
}

#InputStepField: #StepTextField | #StepSelectField

#TriggerStep: {
    trigger: #SlugString

    build?: #BuildAttributes

    label?: string

    async: bool | *false

    branches?: string

    if?: string

    depends_on?: #StepDependencies

    allow_dependency_failure?: bool | *false

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

    depends_on?: #StepDependencies

    allow_dependency_failure?: bool | *false
}

#Notify: [#Notification, ...#Notification]

#Notification: #NotifyBasecamp | #NotifyEmail | #NotifyGitHub | #NotifyPagerDuty | #NotifySlack | #NotifyWebhook

#NotifyOpts: {
    if?: string
}

// TODO: validate URL
#NotifyBasecamp: {
    basecamp_campfire: string

    #NotifyOpts
}

// TODO: validate email pattern
#NotifyEmail: {
    email: string

    #NotifyOpts
}

#NotifyGitHub: {
    github_commit_status: {
        context: string
    }

    #NotifyOpts
}

#NotifyPagerDuty: {
    pagerduty_change_event: string

    #NotifyOpts
}

#NotifySlack: {
    // TODO: validate channel or user pattern [workspace]<#|@>string
    {
        slack: string
    } | {
        slack: null
        channels: [string, ...string]
    }

    message: string

    #NotifyOpts
}

#NotifyWebhook: {
    // TODO: validate URL pattern
    webhook: string

    #NotifyOpts
}
