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
      "set-category.html"
    )
  );
});

// Save Category
router.post("/save", async (req, res) => {
  try {
    const storedProcedureName = "pr_prod_cat_save";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      prod_cat_id:
        req.body.prod_cat_id === null
          ? { type: sql.UniqueIdentifier, output: true }
          : req.body.prod_cat_id,
      prod_cat_desc: req.body.prod_cat_desc,
      is_in_use: req.body.is_in_use,
      display_seq: req.body.display_seq,
      is_global: req.body.is_global,
      co_id: req.body.co_id,
      axn: req.body.axn,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result.output.result);
    const response = {
      data: {
        result: result.output.result,
        prod_cat_id: result.output.prod_cat_id,
        modified_on: new Date().toISOString(), // Current date
        modified_by: req.body.current_uid,
      },
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
    const storedProcedureName = "pr_prod_cat_list";

    const parameters = {
      current_uid: req.body.current_uid,
      prod_cat_id: req.body.prod_cat_id,
      is_in_use: req.body.is_in_use,
      co_id: req.body.co_id,
      axn: req.body.axn, // setup, last-mod-on or null
      my_role_id: req.body.my_role_id,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result.recordsets);
    res.send(result);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

// // Update
// router.post("/update", async (req, res) => {
//   try {
//     const storedProcedureName = "pr_prod_cat_save";

//     const parameters = {
//       current_uid: req.body.current_uid,
//       result: { type: sql.NVarChar, output: true },
//       prod_cat_id: req.body.prod_cat_id,
//       prod_cat_desc: req.body.prod_cat_desc,
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
    const storedProcedureName = "pr_prod_cat_delete";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      prod_cat_id: req.body.prod_cat_id,
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
