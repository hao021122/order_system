const express = require("express");
const router = express.Router();
const bodyParser = require("body-parser");
const path = require("path");
const {
  execStoredProcedure,
  executeSelectStatement,
} = require("../../tools/dbProc");

router.use(bodyParser.urlencoded({ extended: false }));
router.use(bodyParser.json());

router.get("/", (req, res) => {
  res.sendFile(
    path.join(
      __dirname,
      "../../",
      "views",
      "modules",
      "admin",
      "audit_log.html"
    )
  );
});

router.post("/list", async (req, res) => {
  try {
    const storedProcedureName = "pr_task_inbox_list";

    const parameters = {
      startRowIndex: req.body.startRowIndex,
      maximumRows: req.body.maximumRows,
      current_uid: req.body.current_uid,
      co_id: req.body.co_id,
      login_id: req.body.login_id,
      start_dt: req.body.start_dt,
      end_dt: req.body.end_dt,
      app_uid: req.body.app_uid,
      module_id: req.body.module_id,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    res.send(result);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

module.exports = router;
