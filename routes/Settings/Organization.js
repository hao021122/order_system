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

// List
// router.get("/", async (req, res) => {
//   try {
//     const storedProcedureName = "pr_org_list";

//     const parameters = {
//       current_uid: req.body.current_uid,
//       org_row_guid: req.body.org_row_guid,
//     };

//     const result = await execStoredProcedure(storedProcedureName, parameters);
//     console.log(result.output.result);
//     if (result.output.result !== "OK") {
//       return;
//     }
//     res.send(result);
//   } catch (err) {
//     console.error(err);
//     res.status(500).send("Error executing stored procedure: " + err.message);
//   }
// });

// Create Organization
router.post("/create", async (req, res) => {
  try {
    const storedProcedureName = "pr_org_save";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      org_name: req.body.org_name,
      org_img: req.body.org_img,
      org_status_id: req.body.org_status_id,
      org_img_file_name: req.body.org_img_file_name,
      org_row_guid: { type: sql.UniqueIdentifier, output: true },
      url: req.body.url,
      org_code: req.body.org_code,
      is_debug: req.body.is_debug,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result.output.result);
    if (result.output.result !== "OK") {
      return;
    }
    res.send(result);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

module.exports = router;
