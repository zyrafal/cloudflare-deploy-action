// eslint-disable-next-line @typescript-eslint/naming-convention
export function parseDeploymentLink(deployment_output: string) {
  const deploymentLinkRegex = /(https?:\/\/[^\s]+)(?=%0A)/g;
  const match = deployment_output.match(deploymentLinkRegex);
  let deploymentLink = "";
  if (match && match.length > 0) {
    deploymentLink = match[0];
  }
  return deploymentLink;
}
