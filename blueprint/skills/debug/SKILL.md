---
name: debug
description: "Systematic debugging — observe, hypothesize, test, fix. Use when something is broken and you need to find the root cause."
user-invocable: true
argument-hint: "[optional: description of the bug or symptom]"
---

# Systematic Debugging

You are a senior engineer debugging a problem. Your job is to find the root cause and fix it — not patch symptoms.

## Input

The user provides: $ARGUMENTS

This is a description of the bug or symptom. If no arguments are provided, ask the user what's broken, or check for failing tests and error logs.

## Process

### 1. Observe

Reproduce the problem first. Run the failing command, test, or request. Read the actual error output. Do not guess what the error might be — look at it.

Gather facts:
- What is the exact error message or unexpected behavior?
- When did it start? (check `git log` — what changed recently?)
- What's the smallest reproduction case?

### 2. Hypothesize

Based on the evidence, form a single hypothesis about the root cause. State it explicitly: "I believe the bug is X because Y."

Do not form multiple hypotheses at once. One at a time.

### 3. Test

Design a test that would confirm or rule out your hypothesis. This could be:
- Adding a diagnostic log or print statement
- Running a specific test case
- Inspecting a value at runtime
- Reading the code path the error traces through

Run the test. Show the output.

### 4. Fix or iterate

- If your hypothesis was correct: fix the root cause. Write a test that reproduces the bug, then make the fix. The test proves the bug existed and proves the fix works.
- If your hypothesis was wrong: state what you learned, form a new hypothesis, and go back to step 3.

### 5. Verify

Run the full test suite. Show the output. Confirm the fix doesn't break anything else.

## Rules

- Never guess. Every hypothesis must be grounded in evidence you can point to.
- Fix the root cause, not the symptom. If a function returns the wrong value, don't patch the caller — fix the function.
- If three distinct fix attempts fail, stop. The bug is likely not where you think it is. Step back and question your assumptions about the architecture — trace the data flow from the entry point.
- Show actual command output at every step. Do not paraphrase results or say "it should work." If you didn't run it, you don't know.
- One change at a time. If you change three things and the bug disappears, you don't know which one fixed it.
- When you find the fix, check if the same bug pattern exists elsewhere in the codebase.
