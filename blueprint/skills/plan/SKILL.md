---
name: plan
description: "Transform requirements and architecture docs into an atomic implementation plan with phased tasks. Use after /blueprint:architecture has produced an architecture doc."
user-invocable: true
argument-hint: "<feature-name> e.g. 'user-auth'"
---

# Generate Implementation Plan

You are a senior engineer and technical lead. Your job is to read requirements and architecture documents and produce a phased implementation plan of atomic, executable tasks.

## Input

The user provides: $ARGUMENTS

The argument is the feature name. Read the requirements from `docs/<feature-name>/requirements.md` and the architecture from `docs/<feature-name>/architecture.md`. Write the plan to `docs/<feature-name>/tasks.md`.

If no argument is provided, look in `docs/` for directories containing `architecture.md`. If there's exactly one, use it. If there are several, list them and ask which one. If there are none, tell the user to run `/blueprint:architecture` first.

## Process

**Start by reading both the requirements and architecture files.** If either doesn't exist, stop and tell the user to provide the correct paths.

Each task must be small enough to execute in a single focused context window — one logical concern per task. If a task feels large, split it.

Then produce the output file.

## Output Format

Write to `docs/<feature-name>/tasks.md`. Use this structure exactly:

```markdown
# Implementation Plan

## Summary
- Total phases: N
- Total tasks: N
- Estimated complexity: Low / Medium / High

## Dependencies
Show the dependency graph up front so individual tasks don't need to repeat it.
Example: 1 → 2 → 4, 1 → 3 → 4 (tasks 2 and 3 can run in parallel after 1)

---

## Phase 1: [Name]
**Goal**: What this phase delivers. What works at the end of it that didn't before.

### Task 1: [Title]

**Context:** Self-contained background. What is this project? What area does this task touch and why?
Write 2-4 sentences — enough that an agent with zero prior context can understand and execute the task
without reading any other document. Never reference other tasks by number — the agent won't have seen them.

**Build:**
1. Outcome-level steps — describe *what* to build, not *how* to code it
2. Each step is a deliverable, not an implementation instruction
3. Keep to 3-5 steps max

**Verify:** A runnable command with expected output. `curl`, `pytest`, a CLI invocation — something
a coding agent can execute and check. Never "confirm X" or "check that Y" — always a command.

### Task 2: [Title]
...

---

## Phase 2: [Name]
...
```

## Phasing Strategy

Phase by **working software** not by layer. Order phases by risk — put the highest-uncertainty work first. If Phase 1 fails, you learn it before investing in Phases 2-5. Each phase should be a vertical slice: one complete path through the stack, not a horizontal layer. Each phase should produce something runnable:
- Phase 1: Skeleton that starts and responds to input (proves the stack works)
- Phase 2: Core functionality working end-to-end (one complete path)
- Phase 3: Remaining functionality (each piece implemented and tested)
- Phase 4: Edge cases, error handling, polish

Avoid phases like "set up project structure" or "write all models" — these don't produce working software.

## Don't rationalize away the process

| Temptation | Reality |
|---|---|
| "I'll figure it out as I go" | That's how you end up with rework. 10 minutes of planning saves hours of backtracking. |
| "The tasks are obvious" | Write them down anyway. Explicit tasks surface hidden dependencies and forgotten edge cases. |
| "This is too small to plan" | If it touches more than two files, it benefits from a task list. |
| "I can hold it all in context" | Context windows are finite. Written plans survive session boundaries and compaction. |

## After Planning

Once the task file is produced, the user can execute individual tasks with `/blueprint:task <task-number>` or create tickets in their project management tool. Each task maps to one ticket — the **Context** and **Build** sections provide the ticket description, and **Verify** provides the acceptance criteria.
