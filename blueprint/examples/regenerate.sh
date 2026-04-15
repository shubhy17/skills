#!/bin/bash
# Regenerate golden examples using Blueprint skills.
# Run from the repo root: ./examples/regenerate.sh
#
# Requires an interactive Claude Code session because the
# requirements skill asks clarifying questions before writing.
#
# After regeneration, diff the output against the previous examples
# to check for regressions when skills change.

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$DIR/.." && pwd)"
FEATURE="rag-chatbot"

cd "$ROOT"

echo "Run these commands in an interactive Claude Code session:"
echo ""
echo "  /blueprint:requirements $FEATURE $(head -1 "$DIR/input.md")"
echo "  /blueprint:architecture $FEATURE"
echo "  /blueprint:plan $FEATURE"
echo ""
echo "Then copy the outputs:"
echo ""
echo "  cp docs/$FEATURE/requirements.md examples/$FEATURE/"
echo "  cp docs/$FEATURE/architecture.md examples/$FEATURE/"
echo "  cp docs/$FEATURE/tasks.md examples/$FEATURE/"
echo ""
echo "Review the diffs:"
echo "  git diff examples/"
