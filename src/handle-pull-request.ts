import { createAppAuth } from "@octokit/auth-app";
import { Octokit } from "@octokit/rest";

// eslint-disable-next-line @typescript-eslint/naming-convention
export function handlePullRequest(owner: string, repo: string, pull_request_number: string, deploymentLink: string) {
  const octokit = new Octokit({
    authStrategy: createAppAuth,
    auth: {
      appId: process.env.APP_ID,
      privateKey: process.env.APP_PRIVATE_KEY,
      installationId: process.env.APP_INSTALLATION_ID,
    },
  });
  // Post a comment on the pull request
  octokit.pulls
    .createReview({
      owner,
      repo,
      pull_number: Number(pull_request_number),
      body: `Deployment has been done! Here is the [link](${deploymentLink})`,
    })
    .catch(console.error);
}
