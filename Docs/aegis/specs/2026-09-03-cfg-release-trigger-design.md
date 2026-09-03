# Release on Configuration Changes

**Status:** Draft

## Intent

Create a GitHub release when a push to `main` or `master` changes server configuration under `cfg/`, including when no SourcePawn source or compiled plugin output changes.

## Scope

- Add `cfg/**` to the workflow's `push.paths` filter.
- Treat a generated diff in `addons/sourcemod/plugins/` or a `cfg/` diff across the push event's commit range as release-worthy.
- Keep the existing compilation, package contents, and release metadata behavior unchanged.

## Compatibility Boundary

Source-only pushes retain the existing compile-and-release behavior. Pushes that modify neither the compiled plugin tree nor `cfg/` must continue to skip release creation. Manual workflow dispatch remains available.

## Verification

Parse the workflow YAML, confirm both paths are present in the trigger and release-change checks, and run `git diff --check`.
