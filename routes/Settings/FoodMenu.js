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
      "set-food-menu.html"
    )
  );
});

// Create
router.post("/create", async (req, res) => {
  try {
    const storedProcedureName1 = "pr_food_menu_save";

    const parameters1 = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      menu_id: { type: sql.UniqueIdentifier, output: true },
      menu_code: req.body.menu_code,
      menu_desc: req.body.menu_desc,
      is_in_use: req.body.is_in_use,
      display_seq: req.body.display_seq,
      sell_on_web: req.body.sell_on_web,
      sell_in_outlet: req.body.sell_in_outlet,
      co_id: req.body.co_id,
      axn: req.body.axn,
      url: req.body.url,
    };

    const result1 = await execStoredProcedure(
      storedProcedureName1,
      parameters1
    );
    console.log(result1.output.result);
    console.log(result1);
    console.log(result1.output.menu_id);

    if (result1.output.result !== "OK") {
      return;
    }

    const storedProcedureName2 = "pr_food_menu_season_save";

    const parameters2 = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      menu_id: result1.output.menu_id,
      season_id: req.body.season_id,
      display_seq: req.body.display_seq,
      co_id: req.body.co_id,
      axn: req.body.axn,
      url: req.body.url,
    };

    const result2 = await execStoredProcedure(
      storedProcedureName2,
      parameters2
    );
    console.log(result2.output.result);
    console.log(result2);

    if (result2.output.result !== "OK") {
      return;
    }
    const storedProcedureName3 = "pr_food_menu_prod_save";

    const parameters3 = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      menu_id: result1.output.menu_id,
      prod_id: req.body.prod_id,
      display_seq: req.body.display_seq,
      co_id: req.body.co_id,
      axn: req.body.axn,
      url: req.body.url,
    };

    const result3 = await execStoredProcedure(
      storedProcedureName3,
      parameters3
    );
    console.log(result3.output.result);
    console.log(result3);

    res.send({
      result1,
      result2,
      result3,
    });
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

// List
router.post("/list", async (req, res) => {
  try {
    const storedProcedureName = "pr_food_menu_list";

    const parameters = {
      current_uid: req.body.current_uid,
      menu_id: req.body.menu_id,
      is_in_use: req.body.is_in_use,
      menu_code: req.body.menu_code,
      sell_on_web: req.body.sell_on_web,
      sell_in_outlet: req.body.sell_in_outlet,
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

// Update
router.post("/update", async (req, res) => {
  try {
    const storedProcedureName = "pr_food_menu_save";

    const menu_id = req.body.menu_id;
    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      menu_id: req.body.menu_id,
      menu_code: req.body.menu_code,
      is_in_use: req.body.is_in_use,
      display_seq: req.body.display_seq,
      sell_on_web: req.body.sell_on_web,
      sell_in_outlet: req.body.sell_in_outlet,
      co_id: req.body.co_id,
      axn: req.body.axn,
      my_role_id: req.body.my_role_id,
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

// Delete
router.post("/delete", async (req, res) => {
  try {
    const storedProcedureName = "pr_food_menu_delete";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      menu_id: req.body.menu_id,
      co_id: req.body.co_id,
      axn: req.body.axn,
      my_role_id: req.body.my_role_id,
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

module.exports = router;
