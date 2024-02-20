import { execSync } from "child_process";
import { promises as fs } from "fs";
import glob from "glob";
import path from "path";

const ERROR_READING_FILE = "Error reading file:";

export async function findAndLoadFiles() {
  try {
    const cwd = process.cwd();
    console.log(`Current working directory: ${cwd}`);

    const allFiles = glob.sync("**", { cwd, nodir: true, ignore: ["**/node_modules/**"] });

    const appIdFiles = allFiles.filter((file) => path.basename(file) === "app-id");
    const installationIdFiles = allFiles.filter((file) => path.basename(file) === "installation-id");
    const pemFiles = allFiles.filter((file) => path.extname(file) === ".pem");

    console.log("App ID files:", appIdFiles);
    console.log("Installation ID files:", installationIdFiles);
    console.log("PEM files:", pemFiles);

    const appId = await loadFile(appIdFiles[0]);
    const installationId = await loadFile(installationIdFiles[0]);
    const privateKey = await loadFile(pemFiles[0]);

    console.log("App ID:", appId);
    console.log("Installation ID:", installationId);
    console.log("Private Key:", privateKey);
  } catch (err) {
    console.error(ERROR_READING_FILE, err);
  }
}

async function loadFile(filePath: string) {
  try {
    const data = await fs.readFile(filePath, "utf8");
    return data.trim();
  } catch (err) {
    console.error(ERROR_READING_FILE, err);
    return null;
  }
}

export async function printFileStructure(location: string) {
  const command = `find ${location} -not -path '*/node_modules/*'`;
  try {
    const stdout = execSync(command, { encoding: "utf8" });
    console.log(`File structure:\n${stdout}`);
  } catch (error) {
    console.error(`exec error: ${error}`);
  }
}
