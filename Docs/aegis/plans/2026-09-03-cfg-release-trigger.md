# Configuration Release Trigger Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use aegis:subagent-driven-development (recommended) or aegis:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish a release for pushes that change either SourcePawn sources or files below `cfg/`.

**Architecture:** The existing workflow remains the sole owner of compilation, packaging, and release creation. Its path filter receives `cfg/**`; its change-check step evaluates generated plugin changes in the worktree and configuration changes across the GitHub push commit range.

**Tech Stack:** GitHub Actions YAML, Bash, Git.

**Baseline / Authority Refs:** `AGENTS.md`; `Docs/aegis/specs/2026-09-03-cfg-release-trigger-design.md`; `.github/workflows/compile_and_release.yml`.

**Compatibility Boundary:** Manual dispatch, compilation, package contents, and releases caused by compiled plugin changes remain unchanged. A push without generated plugin changes or a `cfg/` diff in its commit range still skips publishing.

**Verification:** Parse the YAML with PyYAML, assert both `cfg/**` and the push-range configuration comparison are present, and run a scoped `git diff --check`.

---

### Task 1: Extend Workflow Release Eligibility

**Files:**
- Modify: `.github/workflows/compile_and_release.yml`

**Why this task exists:**
- Configuration-only changes must start the release workflow and produce the same deployable project archive as plugin changes.

**Impact / Compatibility:**
- The workflow continues to compile source files for each triggered push.
- The release gate changes from plugin-only to plugin-or-configuration, with no new action, secret, package, or deployment target.

**Repair Track:**
- Root cause: `cfg/**` is absent from the push filter and the release gate checks only generated `addons/sourcemod/plugins/` changes; committed configuration changes are absent from the checked-out worktree diff.
- Canonical owner: `.github/workflows/compile_and_release.yml` owns both decisions.
- Smallest change: add one path filter, retain the generated-plugin check, and compare `cfg/` against the push event's before and after commits.
- Verification: the static assertions below must match the modified YAML.

**Retirement Track:**
- The plugin-only release gate is retired.
- No fallback is retained because a configuration change must be release-worthy under the approved specification.

- [ ] **Step 1: Verify the current assertions fail**

Run:

```powershell
$workflow = Get-Content -Raw '.github/workflows/compile_and_release.yml'
if ($workflow -match "- 'cfg/\\*\\*'" -and $workflow -match 'git diff --quiet "${{ github.event.before }}" "${{ github.sha }}" -- cfg/') { exit 1 }
```

Expected: exit code `0`, because the current workflow lacks both configuration conditions.

- [ ] **Step 2: Add the configuration trigger and push-range release check**

Add the following path filter under `on.push.paths`:

```yaml
      - 'cfg/**'
```

Replace the plugin-only check:

```bash
if git diff --quiet addons/sourcemod/plugins/; then
```

with a conditional that preserves the generated plugin check and adds the push-range configuration check:

```bash
if ! git diff --quiet addons/sourcemod/plugins/ || \
   { [ "${{ github.event_name }}" = "push" ] && ! git diff --quiet "${{ github.event.before }}" "${{ github.sha }}" -- cfg/; }; then
```

- [ ] **Step 3: Verify the new assertions pass**

Run:

```powershell
$workflow = Get-Content -Raw '.github/workflows/compile_and_release.yml'
if ($workflow -notmatch "- 'cfg/\\*\\*'") { throw 'Missing cfg trigger path.' }
if ($workflow -notmatch 'git diff --quiet "${{ github.event.before }}" "${{ github.sha }}" -- cfg/') { throw 'Missing push-range configuration check.' }
```

Expected: command exits successfully.

- [ ] **Step 4: Validate syntax and whitespace**

Run:

```powershell
python -c "import yaml; yaml.safe_load(open('.github/workflows/compile_and_release.yml', encoding='utf-8'))"
git diff --check -- .github/workflows/compile_and_release.yml
```

Expected: both commands exit successfully without output.

- [ ] **Step 5: Commit**

```powershell
git add .github/workflows/compile_and_release.yml Docs/aegis/specs/2026-09-03-cfg-release-trigger-design.md Docs/aegis/plans/2026-09-03-cfg-release-trigger.md
git commit -m "ci: release config changes"
```

Commit only when the user requests it; do not include unrelated `cfg` modifications.
