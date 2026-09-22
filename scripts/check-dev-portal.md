# Developer portal Go check

`.github/workflows/check-dev-portal.yml` runs every Monday at 09:00 UTC. You can also start it with **Run workflow** in GitHub Actions. Scheduled runs start only after the workflow is on the default branch. GitHub can delay scheduled runs.

## What it checks

- The default branch of `XRPLF/xrpl-dev-portal`.
- Every directory with non-test `.go` files under `_code-samples`, including examples without a `go.mod`.
- Compilation for Linux on the hosted runner architecture, with CGo disabled.
- The highest stable core version published as a GitHub release in `XRPLF/xrpl-go`. Drafts, prereleases and `confidential/` tags are excluded.

The checker copies Go source into a temporary module. It fixes the xrpl-go dependency to the selected release with both a requirement and a replacement. Other imports resolve through the public Go proxy. The report records the release, portal commit, pinned Go image, package paths and build errors. The checker continues after package failures. Empty discovery fails the check.

This checks source compatibility, not the portal's existing `go.mod`, `go.sum`, vendored dependencies, or workspace configuration. It does not extract inline Markdown snippets. Non-Go assets, including embedded files, are not copied. An example that needs those files will fail and needs a checker update. Examples that need CGo will also fail. No examples, tests, generators or portal scripts are executed. Network and ledger behavior are not tested.

## Isolation

The check uses a disposable GitHub-hosted runner, not a self-hosted runner. The build container:

- Has no GitHub token, wallet secrets, Docker socket, host home directory or writable host mount.
- Receives only copied Go files and the generated module file through a read-only mount.
- Runs as a non-root user with dropped capabilities, a read-only root filesystem and bounded temporary storage, memory, processes and CPU.
- Uses a clean environment, a digest-pinned Go image, the public Go proxy and checksum database. It cannot use VCS fallback or download another Go toolchain.
- Has network access for dependency downloads. Compilation is lower risk than running examples, but it is not risk-free.
- Has a three-minute timeout per package and a forty-minute overall timeout.

Compiler output goes to a log file, not the Actions workflow-command channel. The container cannot access the log file or Actions environment files. Only the separate reporting job has `issues: write`. That job does not download or execute build artifacts.

## Failure reporting

A failed build job opens one bot-owned issue in this repository, or updates and reopens the existing tracked issue. The issue links to the run and its `dev-portal-build-report` artifact. The artifact is retained for 30 days. Setup and dependency download errors also fail the job, so check the logs before changing documentation.

A successful build job comments on and closes an open tracked issue. Cancelled or skipped jobs leave it unchanged. Only runs on this repository's default branch can change issues. Manual runs on another branch can compile examples but cannot change issues.

The workflow needs repository Actions settings that permit issue creation with `GITHUB_TOKEN`. It does not need a personal access token or additional secrets.

## Run locally

To perform a full compilation check, use a disposable machine with Docker and a checkout of the portal:

```sh
python3 scripts/check-dev-portal.py /path/to/xrpl-dev-portal v0.3.1
```

Replace the version with the stable release to check. Inspect `portal-build.log`. Keep the Go image digest in `scripts/check-dev-portal.py` current when maintaining this check.
