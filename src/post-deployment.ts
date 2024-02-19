import { getCliParams } from "./get-cli-params";
import { handleCommit } from "./handle-commit";
import { handlePullRequest } from "./handle-pull-request";
import { parseDeploymentLink } from "./parse-deployment-link";

export async function postDeployment() {
  console.trace({ ...process.env });
  // Create a new Octokit instance
  // Destructure the parameters
  const { deployment_output, repository, pull_request_number, commit_sha } = getCliParams();

  const deploymentLink = parseDeploymentLink(deployment_output);

  // Split the repository into owner and repo
  const [owner, repo] = repository.split("/");

  // Check if pull request number is provided
  if (pull_request_number) {
    handlePullRequest(owner, repo, pull_request_number, deploymentLink, commit_sha);
  } else if (commit_sha) {
    handleCommit(owner, repo, commit_sha, deploymentLink);
  } else {
    console.error("Either pull_request_number or commit_sha must be provided.");
  }
}
