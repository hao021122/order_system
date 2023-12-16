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
      "set-season.html"
    )
  );
});

// Season Save
router.post("/save", async (req, res) => {
  try {
    const storedProcedureName = "pr_season_save";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      season_id:
        req.body.season_id === null
          ? { type: sql.UniqueIdentifier, output: true }
          : req.body.season_id,
      dept_id: req.body.dept_id,
      season_desc: req.body.season_desc,
      start_dt: req.body.start_dt,
      end_dt: req.body.end_dt,
      is_in_use: req.body.is_in_use,
      display_seq: req.body.display_seq,
      is_global: req.body.is_global,
      msg_on_screen: req.body.msg_on_screen,
      co_id: req.body.co_id,
      axn: req.body.axn,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result.output.result);
    res.send(result);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

// List Season
router.post("/list", async (req, res) => {
  try {
    const storedProcedureName = "pr_season_list";

    const parameters = {
      current_uid: req.body.current_uid,
      season_id: req.body.season_id,
      is_in_use: req.body.is_in_use,
      co_id: req.body.co_id,
      axn: req.body.axn, // setup,current, w-curr-marker or null
      my_role_id: req.body.my_role_id,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result.output);
    res.send(result);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

// Update Season
// router.post("/update", async (req, res) => {
//   try {
//     const storedProcedureName = "pr_season_save";

//     const parameters = {
//       current_uid: req.body.current_uid,
//       result: { type: sql.NVarChar, output: true },
//       season_id: req.body.season_id,
//       dept_id: req.body.dept_id,
//       season_desc: req.body.season_desc,
//       start_dt: req.body.start_dt,
//       end_dt: req.body.end_dt,
//       is_in_use: req.body.is_in_use,
//       display_seq: req.body.display_seq,
//       is_global: req.body.is_global,
//       msg_on_screen: req.body.msg_on_screen,
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

// Delete Season
router.post("/delete", async (req, res) => {
  try {
    const storedProcedureName = "pr_season_delete";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      season_id: req.body.season_id,
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

module.exports = router;
