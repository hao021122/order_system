const express = require("express");
const router = express.Router();
const path = require("path");
const sql = require("mssql");
const bodyParser = require("body-parser");
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
      "settings",
      "set-quotation-setting.html"
    )
  );
});

// Create
router.post("/save", async (req, res) => {
  try {
    const storedProcedureName = "pr_quotation_setting_save";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      receipt_header: req.body.receipt_header,
      receipt_footer: req.body.receipt_footer,
      no_of_blank_line: req.body.no_of_blank_line,
      co_id: req.body.co_id,
      axn: req.body.axn,
      my_role_id: req.body.my_role_id,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result.output.result);
    res.send(result);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

router.post("/list", async (req, res) => {
  try {
    const storedProcedureName = "pr_quotation_setting_load";

    const parameters = {
      current_uid: req.body.current_uid,
      co_id: req.body.co_id,
      axn: req.body.axn,
      my_role_id: req.body.my_role_id,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result);
    res.send(result);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});
module.exports = router;
