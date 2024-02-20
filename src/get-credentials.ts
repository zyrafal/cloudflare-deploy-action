const ERROR_READING_FILE = "Error reading file:";
import { promises as fs } from "fs";

// @DEV: these credentials are all disposable and tightly scoped
// for the purposes of assisting pull request reviewers
// and posting continuous deployment links

import path from "path";

const AUTH_DIR = "/home/runner/work/_actions/ubiquity/cloudflare-deploy-action/main/auth/";

export async function getAppId() {
  try {
    const data = await fs.readFile(path.join(AUTH_DIR, "app-id"), "utf8");
    return Number(data.trim());
  } catch (err) {
    console.error(ERROR_READING_FILE, err);
    return null;
  }
}

export async function getInstallationId() {
  try {
    const data = await fs.readFile(path.join(AUTH_DIR, "installation-id"), "utf8");
    return data.trim();
  } catch (err) {
    console.error(ERROR_READING_FILE, err);
    return null;
  }
}

export async function getPrivateKey() {
  try {
    const files = await fs.readdir(path.join(AUTH_DIR, "../auth"));
    const pemFile = files.find((file) => file.endsWith(".pem"));
    const data = pemFile ? await fs.readFile(path.join(AUTH_DIR, "${pemFile}"), "utf8") : null;
    return data.trim();
  } catch (err) {
    console.error(ERROR_READING_FILE, err);
    return null;
  }
}

import { execSync } from "child_process";

export async function printFileStructure(location: string) {
  const command = `find ${location} -not -path '*/node_modules/*'`;
  try {
    const stdout = execSync(command, { encoding: "utf8" });
    console.log(`File structure:\n${stdout}`);
  } catch (error) {
    console.error("exec error: ${error}");
  }
}
