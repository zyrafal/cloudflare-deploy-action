import { postDeployment } from "./post-deployment";

postDeployment()
  .then(() => console.log("Post deployment tasks have been completed."))
  .catch(console.error);
