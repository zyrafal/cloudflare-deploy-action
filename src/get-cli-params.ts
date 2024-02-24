import process from "process";

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
  const args = process.argv.slice(2);
  return parseArgs(args);
}
