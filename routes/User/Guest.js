const express = require("express");
const router = express.Router();
const sql = require("mssql");
const bodyParser = require("body-parser");
const {
  execStoredProcedure,
  executeSelectStatement,
} = require("../../tools/dbProc");

router.use(bodyParser.urlencoded({ extended: false }));
router.use(bodyParser.json());

// Guest Create
router.post("/create", async (req, res) => {
  try {
    const storedProcedureName = "pr_guest_save";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      guest_id: req.body.guest_id,
      guest_name: req.body.guest_name,
      mobile_phone: req.body.mobile_phone,
      email: req.body.email,
      start_dt: req.body.start_dt,
      end_dt: req.body.end_dt,
      co_id: req.body.co_id,
      axn: req.body.axn,
      my_role_id: req.body.my_role_id,
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

// Guest List
router.post("/", async (req, res) => {
  try {
    const storedProcedureName = "pr_guest_list";

    const parameters = {
      current_uid: req.body.current_uid,
      guest_id: req.body.guest_id,
      guest_name: req.body.guest_name,
      mobile_phone: req.body.mobile_phone,
      email: req.body.email,
      co_id: req.body.co_id,
      axn: req.body.axn,
      my_role_id: req.body.my_role_id,
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

// Guest Update
router.post("/update", async (req, res) => {
  try {
    const storedProcedureName = "pr_guest_save";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      guest_id: req.body.guest_id,
      guest_name: req.body.guest_name,
      mobile_phone: req.body.mobile_phone,
      email: req.body.email,
      start_dt: req.body.start_dt,
      end_dt: req.body.end_dt,
      co_id: req.body.co_id,
      axn: req.body.axn,
      my_role_id: req.body.my_role_id,
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

// Guest Delete
router.post("/delete", async (req, res) => {
  try {
    const storedProcedureName = "pr_guest_delete";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      guest_id: req.body.guest_id,
      co_id: req.body.co_id,
      axn: req.body.axn,
      my_role_id: req.body.my_role_id,
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

module.exports = router;
