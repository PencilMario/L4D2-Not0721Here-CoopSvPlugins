# README Refresh Design

## Objective

Update `Docs/readme.md` so it accurately describes the current server configurations and remains practical to maintain.

## Authority

Information is resolved in this order:

1. Active files under `cfg/cfgogl/`
2. Plugin load configuration, especially `cfg/cfgogl/coop_base/shared_plugins.cfg`
3. Current plugin source and command definitions
4. Existing wording in `Docs/readme.md`

When the README conflicts with an active configuration, the active configuration wins.

## Content Structure

The rewritten document will contain:

1. A short usage introduction and table of contents
2. A mode overview grouped by the existing mode families
3. Expandable details for each documented configuration
4. Explanations of special infected spawning, DPS limits, Relax behavior, and related current controls
5. A categorized summary of common plugins and fixes
6. Links to authoritative configuration files for details that change frequently

The full `coop_base` plugin load list will not be duplicated. The README will summarize plugins by function and link to `cfg/cfgogl/coop_base/shared_plugins.cfg`.

## Compatibility Boundary

- Preserve configuration identifiers and intentional display names, including colloquial names.
- Preserve useful operational knowledge that is still supported by repository evidence.
- Do not change game configurations, plugin code, commands, or runtime behavior.
- Do not update the root `README.md` as part of this task.
- Correct obvious typos only when they are not intentional configuration display names.

## Accuracy Rules

- Document only configurations that can be tied to an active directory or clearly identified supported alias.
- Correct stale directory identifiers such as mismatches between documented and actual names.
- Derive mode values from the effective configuration chain, including inherited base files where necessary.
- Remove duplicate claims and unsupported historical explanations.
- Prefer stable descriptions over exhaustive copies of fast-changing load files.

## Verification

- Compare every documented configuration identifier with `cfg/cfgogl/`.
- Search the final README for retired spawn command and ConVar names.
- Validate Markdown headings, local links, fenced code blocks, and paired `<details>` tags.
- Review the final diff to ensure only documentation and task records changed.

## Working Drafts

### Task Intent

Refresh outdated content and improve formatting in `Docs/readme.md`, while preserving the project's configuration names and voice.

### Baseline Read Set

- `Docs/readme.md`: document being replaced
- `cfg/cfgogl/*`: mode definitions and inheritance
- `cfg/cfgogl/coop_base/shared_plugins.cfg`: canonical common plugin load list
- `addons/sourcemod/configs/customvotes.cfg`: current user-facing vote controls
- Current plugin source where configuration files alone do not define semantics

### Impact Statement

The change affects documentation only. Users should gain a more accurate mode reference and clearer navigation. Runtime configuration and existing command compatibility remain outside the change boundary.

## Non-Goals

- Building a README generator
- Renaming configurations or plugins
- Auditing or fixing runtime behavior
- Exhaustively documenting every ConVar or plugin implementation detail
