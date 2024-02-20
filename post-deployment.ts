import { postDeployment } from "./src/post-deployment";

postDeployment()
  .then(() => console.log("Post deployment tasks have been completed."))
  .catch(console.error);
