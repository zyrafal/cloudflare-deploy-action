const ERROR_READING_FILE = "Error reading file:";
import { promises as fs } from "fs";

// @DEV: these credentials are all disposable and tightly scoped
// for the purposes of assisting pull request reviewers
// and posting continuous deployment links

import path from "path";

export async function getAppId() {
  try {
    const data = await fs.readFile(path.resolve(__dirname, "../auth/app-id"), "utf8");
    return data.trim();
  } catch (err) {
    console.error(ERROR_READING_FILE, err);
    return null;
  }
}

export async function getInstallationId() {
  try {
    const data = await fs.readFile(path.resolve(__dirname, "../auth/installation-id"), "utf8");
    return data.trim();
  } catch (err) {
    console.error(ERROR_READING_FILE, err);
    return null;
  }
}

export async function getPrivateKey() {
  try {
    const files = await fs.readdir(path.resolve(__dirname, "../auth"));
    const pemFile = files.find((file) => file.endsWith(".pem"));
    const data = pemFile ? await fs.readFile(path.resolve(__dirname, `../auth/${pemFile}`), "utf8") : null;
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
    console.error(`exec error: ${error}`);
  }
}
