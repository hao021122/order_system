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
      "set-uom.html"
    )
  );
});

// UOM Save
router.post("/save", async (req, res) => {
  try {
    const storedProcedureName = "pr_uom_save";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      uom_id:
        req.body.uom_id === null
          ? { type: sql.UniqueIdentifier, output: true }
          : {
              value: req.body.uom_id,
              type: sql.UniqueIdentifier,
              output: true,
            },
      uom_desc: req.body.uom_desc,
      is_in_use: req.body.is_in_use,
      display_seq: req.body.display_seq,
      is_global: req.body.is_global,
      co_id: req.body.co_id,
      axn: req.body.axn,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result);
    const data = {
      result: result.output.result,
      uom_id: result.output.uom_id,
      modified_on: new Date().toISOString(),
      modified_by: req.body.current_uid,
    };

    // Create the response object
    const response = {
      data: data,
      msg: result.output.result,
    };
    res.send(response);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

// List UOM
router.post("/list", async (req, res) => {
  try {
    const storedProcedureName = "pr_uom_list";

    const parameters = {
      current_uid: req.body.current_uid,
      uom_id: req.body.uom_id,
      is_in_use: req.body.is_in_use,
      co_id: req.body.co_id,
      axn: req.body.axn,
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

// Update UOM
// router.post("/update", async (req, res) => {
//   try {
//     const storedProcedureName = "pr_uom_save";

//     const parameters = {
//       current_uid: req.body.current_uid,
//       result: { type: sql.NVarChar, output: true },
//       uom_id: req.body.uom_id,
//       uom_desc: req.body.uom_desc,
//       is_in_use: req.body.is_in_use,
//       display_seq: req.body.display_seq,
//       is_global: req.body.is_global,
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

// Delete UOM
router.post("/delete", async (req, res) => {
  try {
    const storedProcedureName = "pr_uom_delete";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      uom_id: req.body.uom_id,
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
