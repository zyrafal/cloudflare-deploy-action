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

  const slicedSha = commit_sha.slice(0, 7);
  const body = `<div align="right"><a href="${deploymentLink}"><code>${slicedSha}</code></a></div>`;

  // Get all comments
  octokit.repos
    .listCommentsForCommit({
      owner,
      repo,
      commit_sha,
    })
    .then(({ data }) => {
      const botComment = data.find((comment) => comment.user?.login === "ubiquibot[bot]");
      if (botComment) {
        // If bot comment exists, update it
        return octokit.repos.updateCommitComment({
          owner,
          repo,
          comment_id: botComment.id,
          body: botComment.body + "\n" + body,
        });
      } else {
        // If bot comment does not exist, create a new one
        return octokit.repos.createCommitComment({
          owner,
          repo,
          commit_sha,
          body,
        });
      }
    })
    .catch(console.error);
}
