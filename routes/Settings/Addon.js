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
      "set-addon.html"
    )
  );
});

// Save Addon
router.post("/save", async (req, res) => {
  try {
    // Execeute Stored Procedure
    const storedProcedureName = "pr_addon_save";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      addon_id:
        req.body.addon_id === null
          ? { type: sql.UniqueIdentifier, output: true }
          : {
              value: req.body.addon_id,
              type: sql.UniqueIdentifier,
              output: true,
            },
      addon_code: req.body.addon_code,
      addon_desc: req.body.addon_desc,
      remark: req.body.remark,
      amt: req.body.amt,
      is_in_use: req.body.is_in_use,
      display_seq: req.body.display_seq,
      is_global: req.body.is_global,
      co_id: req.body.co_id,
      axn: req.body.axn,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result);

    // Extract data from the result object
    const data = {
      result: result.output.result,
      addon_id: result.output.addon_id,
      modified_on: new Date().toISOString(),
      modified_by: req.body.current_uid,
    };

    // Create the response object
    const response = {
      data: data,
      msg: result.output.result,
    };

    console.log(response);
    res.send(response);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

// List Addon
// axn (setup or other)
router.post("/list", async (req, res) => {
  try {
    const storedProcedureName = "pr_addon_list";

    const parameters = {
      current_uid: req.body.current_uid,
      addon_id: req.body.addon_id,
      is_in_use: req.body.is_in_use,
      co_id: req.body.co_id,
      axn: req.body.axn, // setup or null
      my_role_id: req.body.my_role_id,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result.recordsets);

    // const data = result.recordsets.map((row) => ({
    //   addon_id: row.addon_id,
    //   addon_code: row.addon_code,
    // }));

    // const response = {
    //   data: data,
    // };
    res.send(result);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

// Delete Addon
router.post("/delete", async (req, res) => {
  try {
    const storedProcedureName = "pr_addon_delete";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      addon_id: req.body.addon_id,
      co_id: req.body.co_id,
      axn: req.body.axn,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result.output.result);
    const response = {
      data: {
        result: result.output.result,
      },
      msg: result.output.result,
    };
    res.send(response);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

module.exports = router;
