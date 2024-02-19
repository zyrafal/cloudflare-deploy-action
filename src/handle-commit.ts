import { createAppAuth } from "@octokit/auth-app";
import { Octokit } from "@octokit/rest";

// eslint-disable-next-line @typescript-eslint/naming-convention
export function handleCommit(owner: string, repo: string, commit_sha: string, deploymentLink: string) {
  const octokit = new Octokit({
    authStrategy: createAppAuth,
    auth: {
      appId: process.env.APP_ID,
      privateKey: process.env.APP_PRIVATE_KEY,
      installationId: process.env.APP_INSTALLATION_ID,
    },
  });
  // Post a comment on the commit
  octokit.repos
    .createCommitComment({
      owner,
      repo,
      commit_sha,
      body: `Deployment has been done! Here is the [link](${deploymentLink})`,
    })
    .catch(console.error);
}
