const express = require("express");
const router = express.Router();
const sql = require("mssql");
const path = require("path");
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
      "set-condiment.html"
    )
  );
});

// Create Condiment
router.post("/save", async (req, res) => {
  try {
    const storedProcedureName = "pr_condiment_save";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      condiment_id:
        req.body.condiment_id === null
          ? { type: sql.UniqueIdentifier, output: true }
          : {
              value: req.body.condiment_id,
              type: sql.UniqueIdentifier,
              output: true,
            },
      condiment_code: req.body.condiment_code,
      condiment_desc: req.body.condiment_desc,
      remarks: req.body.remarks,
      is_in_use: req.body.is_in_use,
      display_seq: req.body.display_seq,
      is_global: req.body.is_global,
      co_id: req.body.co_id,
      axn: req.body.axn,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    // console.log(result.recordset);
    const response = {
      data: {
        result: result.output.result,
        condiment_id: result.output.condiment_id,
        modified_on: new Date().toISOSting(),
        modified_by: req.body.current_uid,
      },
      msg: result.output.result,
    };
    //res.send(result);
    res.send(response);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

// List Condiment
router.post("/list", async (req, res) => {
  try {
    const storedProcedureName = "pr_condiment_list";

    const parameters = {
      current_uid: req.body.current_uid,
      condiment_id: req.body.condiment_id,
      is_in_use: req.body.is_in_use,
      co_id: req.body.co_id,
      axn: req.body.axn, // setup or null
      my_role_id: req.body.my_role_id,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    //console.log(result.recordset);
    const data = result.recordset.map((row) => ({
      condiment_id: row.condiment_id,
      condiment_code: row.condiment_code,
    }));

    const response = {
      data: data,
    };
    res.send(response);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

// Update Condiment
// router.post("/update", async (req, res) => {
//   try {
//     const storedProcedureName = "pr_condiment_save";

//     const parameters = {
//       current_uid: req.body.current_uid,
//       result: { type: sql.NVarChar, output: true },
//       condiment_id: req.body.condiment_id,
//       condiment_code: req.body.condiment_code,
//       condiment_desc: req.body.condiment_desc,
//       remarks: req.body.remarks,
//       is_in_use: req.body.is_in_use,
//       display_seq: req.body.display_seq,
//       is_global: req.body.is_global,
//       co_id: req.body.co_id,
//       axn: req.body.axn,
//       url: req.body.url,
//     };

//     const result = await execStoredProcedure(storedProcedureName, parameters);
//     console.log(result.recordset);
//     res.send(result);
//   } catch (err) {
//     console.error(err);
//     res.status(500).send("Error executing stored procedure: " + err.message);
//   }
// });

// Delete Condiment
router.post("/delete", async (req, res) => {
  try {
    const storedProcedureName = "pr_condiment_delete";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      condiment_id: req.body.condiment_id,
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
