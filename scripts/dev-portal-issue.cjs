// This runs only in the trusted reporting job, not in the build container.
const marker = '<!-- xrpl-go-dev-portal-check -->';

module.exports = async function report({ github, context, env }) {
  const result = env.CHECK_RESULT;
  if (!['success', 'failure'].includes(result)) return;
  const repo = context.repo;
  const run = `${context.serverUrl}/${repo.owner}/${repo.repo}/actions/runs/${context.runId}`;
  // Do not consume compiler output or build artifacts in this privileged job.
  const release = /^v\d+\.\d+\.\d+$/.test(env.RELEASE || '') ? env.RELEASE : 'unresolved';
  const commit = /^[a-f0-9]{40}$/.test(env.PORTAL_SHA || '') ? env.PORTAL_SHA : 'unresolved';
  const issues = await github.paginate(github.rest.issues.listForRepo, {
    ...repo, state: 'all', creator: 'github-actions[bot]', per_page: 100,
  });
  const tracked = issues.filter(issue => !issue.pull_request && issue.body?.startsWith(marker));
  // Prefer an open issue, then the most recently created closed issue.
  tracked.sort((a, b) => Number(b.state === 'open') - Number(a.state === 'open') || b.number - a.number);
  const issue = tracked[0];
  if (result === 'success') {
    if (issue?.state === 'open') {
      await github.rest.issues.createComment({
        ...repo, issue_number: issue.number,
        body: `The Go example check passed against ${release}. [Run and report](${run}).`,
      });
      await github.rest.issues.update({
        ...repo, issue_number: issue.number, state: 'closed', state_reason: 'completed',
      });
    }
    return;
  }
  const body = `${marker}
The developer portal Go example check failed. Check the report and update the documentation examples or their dependencies as needed.

- xrpl-go release: ${release}
- XRPLF/xrpl-dev-portal commit: ${commit}
- [Workflow run and build report](${run})

Download the **dev-portal-build-report** artifact for package paths and compiler errors. If no report exists, check the setup steps. A download or infrastructure failure does not necessarily mean the documentation is broken.

This is a compile-only Linux check. It does not execute examples or check ledger behavior. The next fully successful check will close this issue.
`;
  if (issue) {
    await github.rest.issues.update({
      ...repo, issue_number: issue.number, state: 'open', body,
    });
  } else {
    await github.rest.issues.create({
      ...repo, title: 'Developer portal Go examples need attention', body,
    });
  }
};
