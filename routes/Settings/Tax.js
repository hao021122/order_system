const express = require("express");
const router = express.Router();
const path = require("path");
const sql = require("mssql");
const bodyParser = require("body-parser");
const moment = require("moment");
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
      "set-tax.html"
    )
  );
});

// Tax Save
router.post("/save", async (req, res) => {
  try {
    const storedProcedureName = "pr_tax_save";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      tax_id:
        req.body.tax_id === null
          ? { type: sql.UniqueIdentifier, output: true }
          : {
              value: req.body.tax_id,
              type: sql.UniqueIdentifier,
              output: true,
            },
      tax_code: req.body.tax_code,
      tax_desc: req.body.tax_desc,
      tax_pct: req.body.tax_pct,
      tax_amt: req.body.tax_amt,
      is_in_use: req.body.is_in_use,
      display_seq: req.body.display_seq,
      is_global: req.body.is_global,
      start_dt: req.body.start_dt,
      end_dt: req.body.end_dt,
      co_id: req.body.co_id,
      axn: req.body.axn,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    const data = {
      result: result.output.result,
      tax_id: result.output.tax_id,
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

// List Tax
router.post("/list", async (req, res) => {
  try {
    const storedProcedureName = "pr_tax_list";

    const parameters = {
      current_uid: req.body.current_uid,
      tax_id: req.body.tax_id,
      is_in_use: req.body.is_in_use,
      co_id: req.body.co_id,
      axn: req.body.axn, // setup or null
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

// Update Tax
// router.post("/update", async (req, res) => {
//   try {
//     const storedProcedureName = "pr_tax_save";

//     const parameters = {
//       current_uid: req.body.current_uid,
//       result: { type: sql.NVarChar, output: true },
//       tax_id: req.body.tax_id,
//       tax_code: req.body.tax_code,
//       tax_desc: req.body.tax_desc,
//       tax_pct: req.body.tax_pct,
//       tax_amt: req.body.tax_amt,
//       is_in_use: req.body.is_in_use,
//       display_seq: req.body.display_seq,
//       is_global: req.body.is_global,
//       start_dt: req.body.start_dt,
//       end_dt: req.body.end_dt,
//       co_id: req.body.co_id,
//       axn: req.body.axn,
//       url: req.body.url,
//     };

//     const result = await execStoredProcedure(storedProcedureName, parameters);
//     console.log(result);
//     res.send(result);
//   } catch (err) {
//     console.error(err);
//     res.status(500).send("Error executing stored procedure: " + err.message);
//   }
// });

// Delete Tax
router.post("/delete", async (req, res) => {
  try {
    const storedProcedureName = "pr_tax_delete";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      tax_id: req.body.tax_id,
      co_id: req.body.co_id,
      axn: req.body.axn,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result);
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
