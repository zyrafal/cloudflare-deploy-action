import { config } from "dotenv";
import { postDeployment } from "./src/post-deployment";
config();

postDeployment()
  .then(() => console.log("Post deployment tasks have been completed."))
  .catch(console.error);
