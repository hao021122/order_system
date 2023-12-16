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
      "set-group.html"
    )
  );
});

// Product Group Save
router.post("/save", async (req, res) => {
  try {
    const storedProcedureName = "pr_prod_group_save";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      prod_group_id:
        req.body.prod_group_id === null
          ? { type: sql.UniqueIdentifier, output: true }
          : {
              value: req.body.prod_group_id,
              type: sql.UniqueIdentifier,
              output: true,
            },
      prod_group_desc: req.body.prod_group_desc,
      is_in_use: req.body.is_in_use,
      display_seq: req.body.display_seq,
      is_global: req.body.is_global,
      co_id: req.body.co_id,
      axn: req.body.axn,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result.output.result);
    const data = {
      result: result.output.result,
      prod_group_id: result.output.prod_group_id,
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

// List
router.post("/list", async (req, res) => {
  try {
    const storedProcedureName = "pr_prod_group_list";

    const parameters = {
      current_uid: req.body.current_uid,
      prod_group_id: req.body.prod_group_id,
      is_in_use: req.body.is_in_use,
      co_id: req.body.co_id,
      axn: req.body.axn, // setup or null
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    res.send(result);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

// Update
// router.post("/update", async (req, res) => {
//   try {
//     const storedProcedureName = "pr_prod_group_save";

//     const parameters = {
//       current_uid: req.body.current_uid,
//       result: { type: sql.NVarChar, output: true },
//       prod_group_id: req.body.prod_group_id,
//       prod_group_desc: req.body.prod_group_desc,
//       is_in_use: req.body.is_in_use,
//       display_seq: req.body.display_seq,
//       is_global: req.body.is_global,
//       co_id: req.body.co_id,
//       axn: req.body.axn,
//       url: req.body.url,
//     };

//     const result = await execStoredProcedure(storedProcedureName, parameters);
//     console.log(result.output.result);
//     res.send(result);
//   } catch (err) {
//     console.error(err);
//     res.status(500).send("Error executing stored procedure: " + err.message);
//   }
// });

// Delete
router.post("/delete", async (req, res) => {
  try {
    const storedProcedureName = "pr_prod_group_delete";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      prod_group_id: req.body.prod_group_id,
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
