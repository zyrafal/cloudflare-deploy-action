import { createAppAuth } from "@octokit/auth-app";
import { Octokit } from "@octokit/rest";
import { config } from "dotenv";
import { getCliParams } from "./src/get-cli-params";
config();

async function postDeployment() {
  console.trace({ ...process.env });
  // Create a new Octokit instance

  // Destructure the parameters
  const { deployment_output, repository, pull_request_number, commit_sha } = getCliParams();

  const deploymentLinkRegex = /(https?:\/\/[^\s]+)/g;
  const match = deployment_output.match(deploymentLinkRegex);
  let deploymentLink = "";
  if (match && match.length > 0) {
    deploymentLink = match[0];
  }

  console.trace({ deploymentLink });

  // Split the repository into owner and repo
  const [owner, repo] = repository.split("/");

  // Check if pull request number is provided
  if (pull_request_number) {
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
  } else if (commit_sha) {
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
  } else {
    console.error("Either pull_request_number or commit_sha must be provided.");
  }
}

postDeployment()
  .then(() => console.log("Post deployment tasks have been completed."))
  .catch(console.error);
