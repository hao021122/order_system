const express = require("express");
const router = express.Router();
const path = require("path");
const sql = require("mssql");
const bodyParser = require("body-parser");
const nodemailer = require("nodemailer");

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
      "set-payment-type.html"
    )
  );
});

// Payment Save
router.post("/save", async (req, res) => {
  try {
    const storedProcedureName = "pr_pymt_type_save";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      pymt_type_id:
        req.body.pymt_type_id === null
          ? { type: sql.UniqueIdentifier, output: true }
          : {
              value: req.body.pymt_type_id,
              type: sql.UniqueIdentifier,
              output: true,
            },
      pymt_type_desc: req.body.pymt_type_desc,
      sys_pymt_type_id: req.body.sys_pymt_type_id,
      is_in_use: req.body.is_in_use,
      display_seq: req.body.display_seq,
      is_global: req.body.is_global,
      pymt_type_img_idx: req.body.pymt_type_img_idx,
      allow_payment_change_due: req.body.allow_payment_change_due,
      get_credit_card_detail: req.body.get_credit_card_detail,
      get_ref_no: req.body.get_ref_no,
      co_id: req.body.co_id,
      axn: req.body.axn,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result.recordsets);

    // Extract data from the result object
    const data = {
      result: result.output.result,
      pymt_type_id: result.output.pymt_type_id,
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

// Payment List
router.post("/list", async (req, res) => {
  try {
    const storedProcedureName = "pr_pymt_type_list";

    const parameters = {
      current_uid: req.body.current_uid,
      pymt_type_id: req.body.pymt_type_id,
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

// Sys Payment List
router.post("/sys_pymt_type", async (req, res) => {
  try {
    const storedProcedureName = "pr_sys_pymt_type_list";

    const parameters = {
      current_uid: req.body.current_uid,
      sys_pymt_type_id: req.body.sys_pymt_type_id,
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

// // Payment Update
// router.post("/update", async (req, res) => {
//   try {
//     const storedProcedureName = "pr_pymt_type_save";

//     const parameters = {
//       current_uid: req.body.current_uid,
//       result: { type: sql.NVarChar, output: true },
//       pymt_type_id: req.body.pymt_type_id,
//       pymt_type_desc: req.body.pymt_type_desc,
//       sys_pymt_type_id: req.body.sys_pymt_type_id,
//       is_in_use: req.body.is_in_use,
//       display_seq: req.body.display_seq,
//       is_global: req.body.is_global,
//       pymt_type_img_idx: req.body.pymt_type_img_idx,
//       allow_payment_change_due: req.body.allow_payment_change_due,
//       get_credit_card_detail: req.body.get_credit_card_detail,
//       get_ref_no: req.body.get_ref_no,
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

// Payment Delete
router.post("/delete", async (req, res) => {
  try {
    const storedProcedureName = "pr_pymt_type_delete";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      pymt_type_id: req.body.pymt_type_id,
      co_id: req.body.co_id,
      axn: req.body.axn,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result.recordsets);
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
