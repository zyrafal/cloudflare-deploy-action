const ERROR_READING_FILE = "Error reading file:";
import { promises as fs } from "fs";

// @DEV: these credentials are all disposable and tightly scoped
// for the purposes of assisting pull request reviewers
// and posting continuous deployment links

export async function getAppId() {
  try {
    const data = await fs.readFile("../auth/app-id", "utf8");
    return data.trim();
  } catch (err) {
    console.error(ERROR_READING_FILE, err);
    return null;
  }
}

export async function getInstallationId() {
  try {
    const data = await fs.readFile("../auth/installation-id", "utf8");
    return data.trim();
  } catch (err) {
    console.error(ERROR_READING_FILE, err);
    return null;
  }
}

export async function getPrivateKey() {
  try {
    const files = await fs.readdir("../auth");
    const pemFile = files.find((file) => file.endsWith(".pem"));
    const data = pemFile ? await fs.readFile(`../auth/${pemFile}`, "utf8") : null;
    return data.trim();
  } catch (err) {
    console.error(ERROR_READING_FILE, err);
    return null;
  }
}
