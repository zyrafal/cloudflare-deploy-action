import { getCliParams } from "./get-cli-params";
import { handlePullRequest } from "./handle-pull-request";
import { parseDeploymentLink } from "./parse-deployment-link";

export async function postDeployment() {
  const { deployment_output, repository, pull_request_number, commit_sha } = getCliParams();

  console.trace({ deployment_output, repository, pull_request_number, commit_sha });

  const deploymentLink = parseDeploymentLink(deployment_output);

  // Split the repository into owner and repo
  const [owner, repo] = repository.split("/");

  // Check if pull request number is provided
  if (pull_request_number) {
    handlePullRequest(owner, repo, pull_request_number, deploymentLink, commit_sha);
  } else if (commit_sha) {
    console.info("Skipping commit handling to reduce unnecessary GitHub notifications.");
    // handleCommit(owner, repo, commit_sha, deploymentLink);
  } else {
    console.error("Either pull_request_number or commit_sha must be provided.");
  }
}
