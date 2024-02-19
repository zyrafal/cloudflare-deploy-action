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
