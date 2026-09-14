# Issue Tracker: Beads

This repository uses **Beads (`bd`) as its authoritative and exclusive issue tracker**.

All durable work-tracking state — specifications, implementation tickets, bugs, features, decision tickets, blockers, dependencies, discovered work, progress, and completion state — MUST be recorded in Beads.

Do not use GitHub Issues, GitLab Issues, Markdown issue files, TODO documents, or another issue tracker unless the user explicitly instructs otherwise.

The repository's Beads database is the source of truth for issue state.

---

## Core Rules

1. Use the `bd` CLI for all issue-tracker operations.
2. Prefer `--json` whenever the command supports it.
3. Never infer issue state from prose when Beads can represent it structurally.
4. Use native Beads dependencies for blocking relationships.
5. Use native parent/child relationships for hierarchical work.
6. Use `discovered-from` when new work is discovered while executing another issue.
7. Claim implementation work before modifying the codebase.
8. Do not close an issue until its acceptance criteria are satisfied.
9. Record durable context in the issue before closing it.
10. Never silently replace Beads with another tracker because a skill examples GitHub Issues.
11. When a skill says "issue", "ticket", "tracker", "publish", "child issue", "blocked by", or similar terminology, translate that operation into the corresponding Beads operation described in this document.
12. Issue relationships MUST be represented structurally in Beads whenever Beads provides an appropriate relationship type. Prose may explain a relationship, but MUST NOT be the only representation of it.

---

# Initialization and Repository Detection

Before interacting with issues, verify that the repository is configured for Beads.

Typical initialization:

```bash
bd init
```

Do not run `bd init` automatically if an existing `.beads/` database or Beads configuration is already present.

When beginning a substantial issue-tracker workflow, obtain Beads' repository-specific agent context when useful:

```bash
bd prime
```

Repository-specific Beads configuration and the instructions in this document take precedence over generic assumptions about Beads.

---

# JSON Output

Agents SHOULD prefer machine-readable output:

```bash
bd ready --json
bd list --json
bd show <issue-id> --json
bd update <issue-id> ... --json
bd create ... --json
bd close <issue-id> ... --json
```

Parse structured output rather than scraping human-readable text whenever possible.

Human-readable output is appropriate when the goal is simply to show information to the user.

---

# Issue IDs

Beads issue IDs are canonical references.

Examples:

```text
bd-a1b2
bd-f93c
bd-a1b2.1
bd-a1b2.2
```

Always preserve the exact ID returned by Beads.

Never invent, predict, renumber, or rewrite Beads IDs.

When referring to an issue in:

* another Beads issue;
* a commit message;
* an implementation plan;
* a code-review report;
* a specification;
* a user-facing summary;

use its canonical Beads ID.

---

# Reading Issues

Retrieve an individual issue with:

```bash
bd show <issue-id> --json
```

When an issue is the source of requirements, read its complete relevant context before acting, including:

* title;
* description;
* acceptance criteria;
* current status;
* priority;
* assignee;
* parent;
* dependencies;
* dependents;
* comments;
* labels;
* references to related specifications or decisions.

Do not begin implementation from only the issue title if a description or additional context exists.

---

# Finding Work

The default way to find actionable, unblocked work is:

```bash
bd ready --json
```

To claim ready work atomically when self-selecting:

```bash
bd ready --claim --json
```

For a specific known issue, inspect it first:

```bash
bd show <issue-id> --json
```

Then claim it:

```bash
bd update <issue-id> --claim --json
```

`--claim` is preferred over separately setting an assignee and status because claiming is atomic.

Do not start a blocked issue merely because it appears desirable to work on.

Do not manually approximate readiness by reading issue descriptions if `bd ready` can determine it from the dependency graph.

---

# Listing and Querying Issues

Use `bd list` when looking for issues matching known criteria:

```bash
bd list --json
```

Examples include filtering by:

* status;
* type;
* priority;
* assignee;
* labels.

Use `bd ready` when the semantic question is specifically:

> What work can be started now?

Use `bd blocked` when the semantic question is:

> What work is blocked?

Do not treat `bd list --status open` as equivalent to `bd ready`.

An open issue may still have unresolved blockers.

---

# Issue Types

Use the narrowest semantically correct Beads type available in the repository.

Common mappings:

| Work                                   | Preferred Beads type                                    |
| -------------------------------------- | ------------------------------------------------------- |
| Defect or regression                   | `bug`                                                   |
| User-visible capability                | `feature`                                               |
| Concrete implementation work           | `task`                                                  |
| Large parent scope                     | `epic`                                                  |
| Durable architectural/product decision | `decision` when available                               |
| Maintenance work                       | repository-supported maintenance type, otherwise `task` |

Do not use `epic` merely because an issue is important.

Use an epic when it represents a parent scope containing independently trackable child work.

For Wayfinder, prefer `decision` for decision tickets when the repository's Beads configuration supports it.

If a Wayfinder classification such as `research`, `prototype`, or `grilling` does not correspond to a native Beads issue type, represent it using labels rather than inventing unsupported issue types.

For example:

```text
wayfinder:research
wayfinder:prototype
wayfinder:grilling
wayfinder:decision
```

---

# Priorities

Use Beads priorities consistently:

```text
P0 — critical / immediate
P1 — high
P2 — normal
P3 — low
P4 — backlog / someday
```

Unless repository-specific instructions state otherwise:

* default ordinary work to P2;
* use P0 only for genuinely critical work requiring immediate attention;
* use P1 for urgent or high-impact work;
* use P3 for useful but non-urgent work;
* use P4 for deliberately deferred or speculative backlog work.

Do not inflate priority merely because an issue was newly created.

Priority and dependency are independent concepts.

A P0 issue may still be blocked.

---

# Creating Issues

Create issues with enough context that a fresh agent session can understand and execute them without needing the conversation that created them.

Example:

```bash
bd create "<title>" \
  --type task \
  --priority 2 \
  --description "<description>" \
  --json
```

Exact supported flags may vary by installed Beads version. When uncertain, use:

```bash
bd create --help
```

## Required issue quality

Every implementation issue SHOULD contain, when applicable:

### Context

Why the work exists.

### Objective

What outcome must be achieved.

### Requirements

Concrete behavioral or technical requirements.

### Acceptance Criteria

Observable conditions that must hold before the issue may be closed.

### Constraints

Decisions that implementation must respect.

### References

Relevant:

* Beads issue IDs;
* specification issues;
* decision tickets;
* files;
* modules;
* documentation;
* external references.

Do not create tickets whose body merely repeats the title.

A ticket must preserve enough context to survive a new agent session.

---

# Parent / Child Relationships

Use native Beads hierarchy when an issue is structurally part of a larger issue.

Create a child using:

```bash
bd create "<child title>" \
  --parent <parent-id> \
  --type task \
  --priority 2 \
  --description "<description>" \
  --json
```

Parent/child means:

> This issue is part of this larger scope.

It does NOT mean:

> This issue must be completed before the parent.

It also does NOT automatically mean:

> This issue blocks another sibling.

Use blocking dependencies separately when ordering is required.

Typical hierarchy:

```text
Epic / Spec / Wayfinder Map
├── Child A
├── Child B
├── Child C
└── Child D
```

Prefer one level of useful hierarchy over deeply nested issue trees.

---

# Dependencies and Blocking

Blocking MUST use native Beads dependencies.

If issue A must complete before issue B can start:

```text
A → B
```

then B depends on A:

```bash
bd dep add <issue-B> <issue-A>
```

Read this as:

```text
<issue-B> depends on <issue-A>
```

or equivalently:

```text
<issue-A> blocks <issue-B>
```

## Example

If:

```text
bd-a = create database schema
bd-b = implement API using that schema
```

then:

```bash
bd dep add bd-b bd-a
```

Do NOT reverse this relationship.

---

## Native dependencies are mandatory

When a skill produces:

```text
Ticket B
Blocked by: Ticket A
```

do not merely put:

```markdown
Blocked by: bd-a
```

into Ticket B's description.

Create the native dependency:

```bash
bd dep add bd-b bd-a
```

Prose may additionally mention the dependency for human readability, but the native dependency graph is authoritative.

---

# Dependency Graph Verification

After creating multiple dependent issues, verify the resulting graph.

Useful commands include:

```bash
bd dep tree <issue-id>
```

and:

```bash
bd ready --json
```

The expected ready set should match the intended dependency graph.

If an issue that should be blocked appears as ready, investigate and correct the dependency graph before handing off the work.

If an issue that should be actionable appears blocked, inspect its dependencies rather than bypassing the blocker.

---

# Discovered Work

When implementation, investigation, or review reveals new work that is outside the current issue's acceptance criteria, create a separate issue rather than silently expanding scope.

Create the new issue:

```bash
bd create "<discovered work>" \
  --type <appropriate-type> \
  --priority <priority> \
  --description "<description>" \
  --json
```

Then link it to the issue during which it was discovered:

```bash
bd dep add <new-issue-id> <originating-issue-id> --type discovered-from
```

Example:

```bash
bd dep add bd-new bd-current --type discovered-from
```

This relationship means:

> `bd-new` was discovered while working on `bd-current`.

`discovered-from` is historical/provenance information.

It does NOT necessarily mean the discovered issue is blocked by the originating issue.

If there is also a genuine execution dependency, represent that dependency separately.

Do not expand the current ticket merely to avoid creating a discovered-work issue.

---

# Related Work

Use a non-blocking relationship when two issues are contextually related but neither must complete before the other.

Do not misuse blocking dependencies to mean merely "related".

Similarly:

* hierarchy means decomposition;
* blocking means execution ordering;
* discovered-from means provenance;
* related means contextual association.

Keep those semantics distinct.

---

# Claiming Work

Before implementing a specific issue, claim it:

```bash
bd update <issue-id> --claim --json
```

Claiming establishes ownership and marks the issue as in progress.

Agents that self-select work MUST prefer atomic claim operations to avoid multiple agents starting the same issue.

If another agent has already claimed the issue, do not override ownership without explicit coordination.

---

# Working an Issue

The expected lifecycle for implementation work is:

```text
read
  ↓
verify readiness
  ↓
claim
  ↓
implement
  ↓
validate
  ↓
record durable context
  ↓
close
```

In commands:

```bash
bd show <issue-id> --json
bd update <issue-id> --claim --json

# perform implementation and validation

bd comment <issue-id> "<durable implementation context>"

bd close <issue-id> \
  --reason "<concise completion reason>" \
  --json
```

Do not mark an issue complete before validation.

---

# Comments and Durable Context

Use comments to preserve context that future sessions may need.

Example:

```bash
bd comment <issue-id> "Implemented X using Y because Z. Validation: ..."
```

Good comments include:

* important implementation decisions;
* constraints discovered during implementation;
* investigation results;
* handoff notes;
* test results;
* reasons for deviations from the expected approach;
* links or IDs for discovered work;
* review findings;
* unresolved concerns.

Do not add noisy comments that merely narrate every command executed.

Comments should preserve information with future value.

---

# Closing Issues

Close an issue only when its actual completion criteria are satisfied.

Use:

```bash
bd close <issue-id> \
  --reason "<what was completed>" \
  --json
```

A good close reason briefly states the achieved outcome.

Examples:

```text
Implemented token refresh handling and added coverage for expiration and retry paths.
```

```text
Decision recorded: use PostgreSQL advisory locks for cross-worker serialization.
```

```text
Investigation complete; root cause identified and implementation tickets created.
```

Do NOT close an issue merely because:

* code was written;
* a branch was created;
* a PR was opened;
* investigation started;
* another issue was created;
* the agent reached the end of its context window.

Before closing implementation work, verify the acceptance criteria.

---

# Reopening Issues

If a supposedly completed issue no longer satisfies its acceptance criteria, reopen it rather than creating a duplicate unless the new work is materially distinct.

Preserve the previous history.

Add context explaining why the issue was reopened.

---

# Specifications

Specifications are durable decision records and MUST live in Beads when a skill publishes them to the issue tracker.

A specification should preserve:

* problem/context;
* agreed scope;
* requirements;
* constraints;
* relevant domain language;
* important decisions;
* explicitly rejected alternatives where relevant;
* acceptance criteria;
* unresolved items, if any;
* references to originating decisions or Wayfinder map.

A specification is not an implementation ticket.

Do not claim a specification simply because implementation begins.

When implementation tickets are derived from a specification, link or reference the specification from every ticket sufficiently to allow provenance to be reconstructed.

When appropriate, make implementation tickets children of the specification or its implementation epic.

---

# `/to-spec`

When the `to-spec` skill says to publish the resulting specification to the issue tracker:

1. Create a Beads issue containing the complete specification.
2. Use the repository's appropriate specification type if one exists.
3. Otherwise use the closest durable non-implementation type supported by the repository.
4. Preserve all decisions made during grilling/planning.
5. Return the created Beads issue ID to the user.
6. Treat that ID as the canonical reference for subsequent `/to-tickets`, `/code-review`, or implementation work.

Do NOT create a GitHub Issue.

Do NOT save the specification only as a Markdown tracker file.

If the specification also exists as repository documentation, the Beads issue remains the tracking record and should reference the document.

---

# `/to-tickets`

`to-tickets` converts an implementation-ready specification into executable Beads issues.

The resulting ticket graph MUST be represented using native Beads relationships.

## Ticket creation procedure

For each ticket:

1. determine its objective;
2. choose the appropriate issue type;
3. determine its priority;
4. create the issue;
5. preserve its returned Beads ID;
6. link it to its parent/spec when appropriate;
7. after all IDs are known, create native blocking dependencies;
8. verify the final ready frontier.

Create all tickets before creating dependencies when doing so makes ID resolution simpler.

---

## Ticket requirements

Each implementation ticket SHOULD be independently understandable.

Include:

* context;
* objective;
* requirements;
* acceptance criteria;
* constraints;
* relevant files/modules if known;
* specification reference;
* dependencies where useful for humans.

Do not rely on the ticket's position in a generated list to carry meaning.

---

## Blocking graph

Suppose `to-tickets` produces:

```text
A: Establish persistence model
B: Implement write path
C: Implement read path
D: Integrate API
E: Add end-to-end flow
```

with:

```text
A blocks B
A blocks C
B and C block D
D blocks E
```

After creating the Beads issues, encode:

```bash
bd dep add <B> <A>
bd dep add <C> <A>
bd dep add <D> <B>
bd dep add <D> <C>
bd dep add <E> <D>
```

Then verify:

```bash
bd ready --json
```

Only the intended frontier should be ready.

---

## Tracer-bullet ordering

When the skill intentionally designs tickets as vertical slices or tracer bullets, preserve that ordering in the dependency graph.

Do not reorganize the graph into technical layers merely because that is easier to categorize.

The dependency graph must reflect the implementation strategy decided by the skill.

---

## Output from `/to-tickets`

After publishing tickets, report at minimum:

* specification issue ID;
* created Beads issue IDs and titles;
* dependency relationships;
* which issues are currently ready;
* any intentionally deferred work.

Do not report publishing as successful until the issues and required dependencies actually exist in Beads.

---

# `/wayfinder`

Wayfinder uses Beads as a durable map of unresolved decisions.

Wayfinder **plans and resolves uncertainty; it does not implement the resulting product work**.

A Wayfinder decision ticket must result in a decision, finding, or resolved uncertainty — not implementation.

---

## Wayfinder map

Represent each Wayfinder effort with one parent issue: the **map**.

Prefer an `epic` or repository-approved equivalent for the map.

Apply a label such as:

```text
wayfinder:map
```

The map should contain:

* destination / desired outcome;
* current known context;
* decisions already made;
* remaining fog;
* links or IDs for child decision tickets;
* concise resolved-decision summaries.

The map is an index and summary.

The authoritative detailed resolution for a decision belongs in its decision ticket.

---

## Wayfinder decision tickets

Create each unresolved decision as a child of the map:

```bash
bd create "<decision question>" \
  --parent <map-id> \
  --type decision \
  --priority 2 \
  --description "<decision context>" \
  --json
```

If `decision` is not available as a native type, use `task` plus an explicit Wayfinder label.

Each decision ticket MUST contain:

### Question

The exact uncertainty to resolve.

### Why it matters

What downstream choices depend on this answer.

### Context

Known constraints, evidence, and previous decisions.

### Resolution criteria

What evidence or decision is sufficient to consider the question resolved.

### Result

Filled in when the ticket is resolved.

---

## Wayfinder ticket classifications

When useful, classify Wayfinder tickets with labels:

```text
wayfinder:research
wayfinder:prototype
wayfinder:grilling
wayfinder:decision
```

Interpretation:

### `wayfinder:research`

Resolve by examining existing systems, documentation, code, data, or external facts.

### `wayfinder:prototype`

Resolve by creating the smallest disposable experiment necessary to answer the question.

The prototype exists to make a decision, not to become production implementation automatically.

### `wayfinder:grilling`

Resolve through structured user decisions.

When asking the user questions, follow the agent's configured native interaction mechanism.

### `wayfinder:decision`

Resolve by synthesizing existing evidence into a durable decision.

These labels describe how uncertainty is resolved. They are not implementation categories.

---

# Wayfinder Dependencies

Decision tickets may depend on other decisions.

If decision A must be resolved before decision B can reasonably be answered:

```bash
bd dep add <B> <A>
```

The Wayfinder frontier is the set of unresolved, unblocked decision tickets.

Use:

```bash
bd ready --json
```

together with the Wayfinder map/labels to identify candidates.

Do not work on a blocked decision unless the blocker relationship itself is found to be incorrect.

---

# Resolving a Wayfinder Decision

Before resolving a decision ticket:

1. obtain sufficient evidence;
2. make or obtain the decision;
3. record the decision durably in the ticket;
4. record rationale and important consequences;
5. update the map's concise decisions-so-far context when needed;
6. close the decision ticket.

Example durable comment:

```bash
bd comment <decision-id> \
  "Decision: use X. Rationale: Y. Consequences: Z. Rejected alternative: W because ..."
```

Then:

```bash
bd close <decision-id> \
  --reason "Decision resolved and recorded" \
  --json
```

Never close a decision ticket with only:

```text
Done
```

The decision itself must survive the session.

---

# Completing a Wayfinder Map

A Wayfinder map is complete when:

* every required decision has been resolved;
* there is no meaningful implementation-blocking fog remaining;
* resolved decisions are durably recorded;
* the intended implementation path can be explained;
* unresolved implementation work can now be specified.

At that point:

1. record the final high-level route on the map;
2. close the map if the Wayfinder workflow considers it complete;
3. hand off to `/to-spec` or the appropriate specification workflow.

Do NOT continue directly into implementation merely because the Wayfinder map is clear.

Wayfinder stops when the path is clear.

---

# `/implement`

When implementation is driven by a Beads issue:

## Before coding

Retrieve it:

```bash
bd show <issue-id> --json
```

Verify:

* it is the intended issue;
* requirements are understandable;
* acceptance criteria exist or completion is otherwise objectively clear;
* blockers are resolved;
* relevant specification/decision context has been read.

Claim it:

```bash
bd update <issue-id> --claim --json
```

## During implementation

Stay within the issue's scope.

If new independent work is discovered:

1. create another Beads issue;
2. link it with `discovered-from`;
3. continue the current issue only if its own acceptance criteria can still be satisfied.

Record durable implementation context when useful:

```bash
bd comment <issue-id> "<context>"
```

## Before completion

Validate the work against:

* issue requirements;
* acceptance criteria;
* relevant specification;
* relevant decision tickets;
* repository-required tests/checks.

Then close:

```bash
bd close <issue-id> \
  --reason "<validated outcome>" \
  --json
```

---

# `/code-review`

When `code-review` needs an originating issue or specification, Beads is the source of truth.

Retrieve the referenced issue:

```bash
bd show <issue-id> --json
```

Use its:

* description;
* acceptance criteria;
* comments;
* parent context;
* related specification;
* relevant decision tickets;

as input to the review's specification axis.

Do not query GitHub Issues for specification context unless the user explicitly asks for external GitHub issue information.

Do not assume the implementation is correct merely because its originating Beads issue is closed.

Review the actual implementation against the recorded requirements.

---

## Findings discovered by code review

When a review identifies concrete follow-up work that should be tracked:

1. create a Beads issue of the appropriate type;
2. include evidence and impact;
3. reference the reviewed issue;
4. use `discovered-from` when the finding was discovered during that review/work;
5. create blocking relationships only when there is a genuine execution dependency.

Example:

```bash
bd create "Handle token refresh race" \
  --type bug \
  --priority 1 \
  --description "<finding and reproduction>" \
  --json
```

Then:

```bash
bd dep add <new-issue> <reviewed-issue> --type discovered-from
```

Do not turn every minor stylistic review comment into an issue.

Persist findings that represent real work, risk, defects, missing requirements, or intentionally deferred follow-up.

---

# `/triage`

When triaging Beads issues:

* preserve the issue's canonical ID;
* inspect the full issue before changing it;
* apply the repository's triage vocabulary consistently;
* adjust priority only when evidence warrants it;
* use labels for categorization;
* use dependencies for actual blocking;
* avoid encoding workflow state solely through labels if Beads already has a native status field.

Do not close duplicate, invalid, or obsolete issues without recording why.

When one issue duplicates another and Beads supports an appropriate relationship, represent that relationship structurally.

---

# Status Semantics

Prefer Beads' native lifecycle.

At minimum, distinguish:

```text
open
in_progress
closed
```

Do not invent custom statuses unless the repository has explicitly configured them.

Interpretation:

### Open

The issue exists but is not currently owned as active work.

An open issue may be ready or blocked.

### In progress

Someone has claimed or begun active work.

### Closed

The issue's intended outcome has been completed or the issue has been intentionally terminated with an explanatory reason.

Readiness and status are separate.

An issue can be:

```text
open + ready
open + blocked
```

Use the dependency graph to determine readiness.

---

# Labels

Use labels for classification, not for relationships already modeled natively.

Good label uses:

```text
wayfinder:map
wayfinder:research
wayfinder:prototype
wayfinder:grilling
needs-review
security
performance
frontend
backend
```

Poor label uses:

```text
blocked-by-bd-a12
parent-bd-f93
depends-on-X
```

Those relationships belong in the native graph.

Avoid uncontrolled label proliferation.

Reuse the repository's existing vocabulary where possible.

---

# Multi-Agent Coordination

Beads is designed to support multiple agents working from the same issue graph.

When self-selecting a task, use atomic claiming:

```bash
bd update <issue-id> --claim --json
```

or:

```bash
bd ready --claim --json
```

Do not independently begin an issue already owned by another agent.

For explicit assignment:

```bash
bd assign <issue-id> <agent>
```

When handing work to another agent, leave a durable comment explaining:

* current state;
* what was completed;
* what remains;
* validation already performed;
* relevant risks or decisions.

Example:

```bash
bd comment <issue-id> \
  "Handoff: API implementation complete. Remaining: integration tests for retry behavior. See bd-xyz for discovered edge case."
```

Then assign as appropriate.

---

# Session-End Durability

Before ending a session involving issue-tracker changes:

1. ensure newly discovered durable work exists in Beads;
2. ensure required relationships were created;
3. record important handoff context;
4. ensure active issues accurately reflect their current status;
5. do not leave completed issues in progress;
6. do not close unfinished issues merely to clean up state.

If this repository uses a shared Dolt remote, follow its configured synchronization workflow.

When appropriate, Beads supports:

```bash
bd dolt push
```

Do not invent a synchronization workflow if the repository has its own explicit Beads/Dolt instructions.

---

# Command Verification

Beads evolves.

If a command or flag in this document appears unsupported by the installed version, do not guess.

Check the installed CLI:

```bash
bd --help
bd <command> --help
```

Examples:

```bash
bd create --help
bd update --help
bd dep --help
bd close --help
```

Prefer the installed CLI's documented equivalent while preserving the semantics required by this document.

Do not silently fall back to another issue tracker because of a CLI syntax difference.

---

# Tracker Translation Rules for Skills

Skills may have been written using GitHub Issues terminology.

Translate their intent into Beads operations.

| Skill terminology        | Beads operation                               |
| ------------------------ | --------------------------------------------- |
| Create/publish issue     | `bd create`                                   |
| Fetch/read issue         | `bd show <id> --json`                         |
| List issues              | `bd list --json`                              |
| Find actionable work     | `bd ready --json`                             |
| Claim/start issue        | `bd update <id> --claim --json`               |
| Add comment/context      | `bd comment <id> "..."`                       |
| Close/resolve issue      | `bd close <id> --reason "..." --json`         |
| Parent/child issue       | `bd create ... --parent <id>`                 |
| A blocks B               | `bd dep add <B> <A>`                          |
| Discovered during A      | `bd dep add <new> <A> --type discovered-from` |
| Inspect dependency graph | `bd dep tree <id>`                            |
| Find blocked work        | `bd blocked`                                  |

The semantic instruction from the skill should be preserved.

Only the tracker mechanism changes.

For example, if a skill says:

```text
Create a GitHub issue for every implementation ticket and establish
native blocking relationships.
```

interpret it as:

```text
Create a Beads issue for every implementation ticket and establish
native Beads blocking relationships.
```

Do not invoke `gh issue`.

---

# Forbidden Patterns

Agents MUST NOT:

* use `gh issue create` for repository work tracked in Beads;
* create Markdown issue files as a substitute for Beads;
* keep required tickets only in chat;
* put dependencies only in prose;
* invent Beads issue IDs;
* reverse dependency direction;
* start blocked implementation work without resolving or correcting blockers;
* overwrite another agent's claim without coordination;
* close work before validating its acceptance criteria;
* treat a parent-child relationship as equivalent to blocking;
* treat `discovered-from` as equivalent to blocking;
* convert Wayfinder decision tickets into implementation tickets;
* implement code as part of Wayfinder merely because the decisions are resolved;
* discard unresolved discovered work because it is outside the current ticket;
* query GitHub Issues merely because a skill was originally designed around GitHub;
* silently fall back to another tracker if a Beads command fails;
* store important decisions solely in ephemeral chat context.

---

# Canonical Agent Workflow

For ordinary implementation:

```bash
# 1. Find work
bd ready --json

# 2. Inspect selected issue
bd show <issue-id> --json

# 3. Claim atomically
bd update <issue-id> --claim --json

# 4. Implement and validate
# ...

# 5. Record important durable context if needed
bd comment <issue-id> "<implementation / validation context>"

# 6. Create and link discovered work if necessary
bd create "<discovered work>" ... --json
bd dep add <new-id> <issue-id> --type discovered-from

# 7. Close only after acceptance criteria are satisfied
bd close <issue-id> \
  --reason "<completed outcome>" \
  --json

# 8. Inspect the new frontier
bd ready --json
```

---

# Canonical Planning Workflow

For a decided but multi-session effort:

```text
grilling / planning
        ↓
      to-spec
        ↓
 Beads specification
        ↓
    to-tickets
        ↓
 Beads ticket graph
        ↓
    bd ready
        ↓
 implementation
        ↓
   code-review
```

For an effort whose destination is known but whose route is still uncertain:

```text
    wayfinder
        ↓
 Beads map issue
        ↓
 decision children
        ↓
dependency-driven frontier
        ↓
resolved decisions
        ↓
      to-spec
        ↓
    to-tickets
        ↓
 implementation
```

Beads is the durable state boundary between every stage.

---

# Source of Truth

When tracker-related instructions conflict:

1. explicit user instruction for the current task;
2. repository-specific instructions;
3. this `docs/agents/issue-tracker.md`;
4. skill-specific generic issue-tracker instructions;
5. examples that happen to use GitHub Issues or another tracker.

A skill's workflow semantics should still be respected.

However, generic examples or assumptions about GitHub Issues MUST NOT override this repository's explicit choice of Beads as its issue tracker.

**For this repository: Issue Tracker means Beads.**

