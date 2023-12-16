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
      "set-request.html"
    )
  );
});

// Request Save
router.post("/save", async (req, res) => {
  try {
    const storedProcedureName = "pr_request_save";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      request_id:
        req.body.request_id === null
          ? { type: sql.UniqueIdentifier, output: true }
          : {
              value: req.body.request_id,
              type: sql.UniqueIdentifier,
              output: true,
            },
      request_code: req.body.request_code,
      request_desc: req.body.request_desc,
      remarks: req.body.remarks,
      group_code: req.body.group_code,
      is_in_use: req.body.is_in_use,
      display_seq: req.body.display_seq,
      is_global: req.body.is_global,
      co_id: req.body.co_id,
      axn: req.body.axn,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    // console.log(result.recordsets);
    // console.log(result.result);
    // res.send({
    //   data: result.result,
    //   output: result.output,
    // });
    // Accessing individual output parameter values directly from the 'parameters' object
    // const resultValue = parameters.result; // 'OK'
    // const requestId = parameters.request_id; // '6AD7C021-5E5A-483C-9035-EE56954739AC'

    // console.log("Result Value:", resultValue);
    // console.log("Request ID:", requestId);
    // console.log(output.result);
    // console.log(output.request_id);
    const data = {
      result: result.output.result,
      request_id: result.output.request_id,
      modified_on: new Date().toISOString(),
      modified_by: req.body.current_uid,
    };

    const response = {
      data: data,
      msg: result.output.result,
    };
    console.log(response);
    console.log(result);
    // Sending the result as part of the response to the client
    res.send(response);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

// List Request
router.post("/list", async (req, res) => {
  try {
    const storedProcedureName = "pr_request_list";

    const parameters = {
      current_uid: req.body.current_uid,
      request_id: req.body.request_id,
      is_in_use: req.body.is_in_use,
      co_id: req.body.co_id,
      axn: req.body.axn, // setup or null
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

router.post("/request_group", async (req, res) => {
  try {
    const storedProcedureName = "pr_request_group_list";

    const parameters = {
      current_uid: req.body.current_uid,
      co_id: req.body.co_id,
      axn: req.body.axn,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result.recordsets);
    // const data = result.recordsets.map((row) => ({
    //   request_group_code: row.request_group_code,
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

// Update Request
// router.post("/update", async (req, res) => {
//   try {
//     const storedProcedureName = "pr_request_save";

//     const parameters = {
//       current_uid: req.body.current_uid,
//       result: { type: sql.NVarChar, output: true },
//       request_id: req.body.request_id,
//       request_code: req.body.request_code,
//       request_desc: req.body.request_desc,
//       remarks: req.body.remarks,
//       group_code: req.body.group_code,
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

// Delete Request
router.post("/delete", async (req, res) => {
  try {
    const storedProcedureName = "pr_request_delete";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      request_id: req.body.request_id,
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
