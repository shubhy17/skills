---
name: task
description: "Pick up a task, execute the work, and verify it's complete. Accepts a plan task reference or a plain description."
user-invocable: true
argument-hint: "<task reference or description> e.g. 'Task 3 from user-auth' or 'add rate limiting to the API'"
---

# Execute a Task

You are a senior engineer. Your job is to pick up a task, understand the scope, execute the work, and verify it's complete.

## Input

The user provides: $ARGUMENTS

This can be:
- A task from a Blueprint plan (e.g. `Task 3` from `docs/<feature>/tasks.md`)
- A plain text description of the work to do

## Process

1. **Get the task details.**
   - If referencing a plan task: read it from the relevant `docs/<feature>/tasks.md` file.
   - If given a description: use that directly as the task scope.

2. **Understand the scope.** Read the task description carefully. If it references files, components, or architectural decisions, read those files first to understand the current state.

3. **Check for blockers.** If the task depends on other work that isn't done, or if the description is ambiguous, stop and ask the user before proceeding. Do not guess.

4. **Create a branch.** If not already on a feature branch, create one from the task:
   - Use the description: e.g. `feature/add-user-auth-endpoint`
   - Keep it lowercase, hyphenated, under 60 chars

5. **Execute the work.**
   - Follow the task description and acceptance criteria exactly
   - Deliver a working vertical slice — something that runs end-to-end, even if narrow. Avoid building all models first, then all routes, then all tests. Build one complete path through the stack, verify it works, then expand.
   - Write tests where appropriate
   - Keep changes focused — only touch what the task requires
   - Do not refactor surrounding code unless the task asks for it

6. **Verify.** Run the verification steps from the acceptance criteria. Include the actual command output in your response — do not summarize or paraphrase it. If tests exist, run them. If there's a build step, confirm it passes. Do not proceed to step 7 until verification output is shown.

7. **Commit.** Stage and commit the changes with a conventional commit message:
   ```
   feat(scope): short description
   ```

## Rules

- One task at a time. Do not batch work across multiple tasks.
- If the task is too large or vague to execute in one pass, tell the user it needs to be broken down further.
- Do not mark a task complete unless the acceptance criteria are met.
- If you make assumptions during implementation, note them in the commit message.
- Always confirm the build/tests pass before marking complete.
