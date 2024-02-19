/**
 * This is a test for now, but it will be used to run post-deployment tasks
 */

// Import the process module from Node.js to access command line arguments
import process from "process";

// Define a function to parse arguments into an object
function parseArgs(args: string[]): Record<string, string> {
  const argObject: Record<string, string> = {};
  for (let i = 0; i < args.length; i += 2) {
    const key = args[i].replace("--", "");
    const value = args[i + 1];
    argObject[key] = value;
  }
  return argObject;
}

export function getCliParams() {
  // Parse command line arguments
  const args = process.argv.slice(2);
  // Use the function to parse arguments
  return parseArgs(args);
}

// // Create a module to return the CLI params
// const cliParams = (() => {
//   // Log the command line arguments
//   console.trace("Command line arguments:", process.argv);
//   // Parse command line arguments
//   const args = process.argv.slice(2);
//   // Use the function to parse arguments
//   const parsedArgs = parseArgs(args);
//   return parsedArgs;
// })();

// // Extract variables from parsed arguments
// const url = cliParams.url;
// const repository = cliParams.repository;
// const pullRequestNumber = cliParams.pull_request_number;
// const commitSha = cliParams.commit_sha;

// console.trace("URL:", url);
// console.trace("Repository:", repository);
// console.trace("Pull request number:", pullRequestNumber);
// console.trace("Commit SHA:", commitSha);
