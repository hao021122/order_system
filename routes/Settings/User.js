const express = require("express");
const router = express.Router();
const path = require("path");
const sql = require("mssql");
const bcrypt = require("bcrypt");
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
      "set-user.html"
    )
  );
});

// Create User
router.post("/save", async (req, res) => {
  try {
    const storedProcedureName1 = "pr_admin_create_user_save";

    const saltRounds = await bcrypt.genSalt();
    const { pwd } = req.body;
    const hashPwd = await bcrypt.hash(pwd, saltRounds);

    const parameters1 = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      user_id:
        req.body.user_id === null
          ? { type: sql.UniqueIdentifier, output: true }
          : {
              value: req.body.user_id,
              type: sql.UniqueIdentifier,
              output: true,
            },
      login_id: req.body.login_id,
      user_name: req.body.user_name,
      user_status_id: req.body.user_status_id,
      user_type_id: req.body.user_type_id,
      pwd: hashPwd,
      // login_validity_start: req.body.login_validaty_start,
      // login_validity_end: req.body.login_validity_end,
      url: req.body.url,
      module_id: req.body.module_id,
      // wl: req.body.wl,
    };

    const result1 = await execStoredProcedure(
      storedProcedureName1,
      parameters1
    );
    console.log(result1);
    console.log(result1.output.result);
    if (
      result1.output.result !== "OK" &&
      result1.output.result !== "User Updated Successfully!!!"
    ) {
      return;
    }

    const storedProcedureName2 = "pr_co_list";

    const parameters2 = {
      current_uid: req.body.current_uid,
      org_row_guid: req.body.org_row_guid,
      co_row_guid: req.body.co_row_guid,
    };

    const result2 = await execStoredProcedure(
      storedProcedureName2,
      parameters2
    );
    console.log(result2.recordsets);

    const storedProcedureName3 = "pr_user_co_list_save";

    const id = result2.recordsets[0][0].co_row_guid + "+" + req.body.ids;
    console.log(id);
    const parameters3 = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      user_id: result1.output.user_id,
      ids: id.trim(),
      url: req.body.url,
    };

    const result3 = await execStoredProcedure(
      storedProcedureName3,
      parameters3
    );
    console.log(result3);
    const data1 = {
      result: result1.output.result,
      user_id: result1.output.user_id,
    };
    const data3 = {
      result: result3.output.result,
    };

    const response = {
      response1: {
        data: data1,
        msg: result1.output.result,
      },
      response3: {
        data: data3,
        msg: result3.output.result,
      },
    };
    res.send(response);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

router.post("/t", async (req, res) => {
  try {
    const storedProcedureName = "pr_user_type_list";

    const parameters = {
      current_uid: req.body.current_uid,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result.recordsets);
    res.send(result);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

router.post("/g", async (req, res) => {
  try {
    const storedProcedureName = "pr_user_group_list";

    const parameters = {
      current_uid: req.body.current_uid,
      user_group_id: req.body.user_group_id,
      show_active_rec: req.body.show_active_rec,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result.recordsets);
    res.send(result);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

// List User
router.post("/list", async (req, res) => {
  try {
    const storedProcedureName = "pr_user_list";

    const parameters = {
      startRowIndex: req.body.startRowIndex,
      maximumRows: req.body.maximumRows,
      current_uid: req.body.current_uid,
      login_id: req.body.login_id,
      user_name: req.body.user_name,
      user_type_id: req.body.user_type_id,
      user_status_id: req.body.user_status_id,
      co_row_guid: req.body.co_row_guid,
      //is_debug: req.body.is_debug,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result.recordsets);
    res.send(result);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

// Delete User
router.post("/delete", async (req, res) => {
  try {
    const storedProcedureName = "pr_user_delete";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      delete_user_id: req.body.delete_user_id,
      co_row_guid: req.body.co_row_guid,
      url: req.body.url,
      module_id: req.body.module_id,
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
