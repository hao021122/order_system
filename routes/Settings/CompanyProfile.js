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
      "set-outlet-profile.html"
    )
  );
});

// Create Company Profile
router.post("/save", async (req, res) => {
  try {
    const storedProcedureName = "pr_co_save";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      co_name: req.body.co_name,
      reg_no: req.body.reg_no,
      addr1: req.body.addr1,
      addr2: req.body.addr2,
      postcode: req.body.postcode,
      city: req.body.city,
      state: req.body.state,
      country: req.body.country,
      phone: req.body.phone,
      fax: req.body.fax,
      email: req.body.email,
      mobile_phone: req.body.mobile_phone,
      co_status_id: req.body.co_status_id,
      org_row_guid: req.body.org_row_guid,
      co_row_guid: { type: sql.UniqueIdentifier, output: true },
      url: req.body.url,
      co_code: req.body.co_code,
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
    const storedProcedureName = "pr_co_profile_load";

    const parameters = {
      current_uid: req.body.current_uid,
      org_row_guid: req.body.org_row_guid,
      co_row_guid: req.body.co_row_guid,
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
