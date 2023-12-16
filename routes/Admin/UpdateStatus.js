const express = require("express");
const router = express.Router();
const sql = require('mssql')
const bodyParser = require("body-parser");
const {
  execStoredProcedure,
  executeSelectStatement,
} = require("../../tools/dbProc");

router.use(bodyParser.urlencoded({ extended: false }));
router.use(bodyParser.json());

router.post("/", async (req, res) => {
    try {
        const storedProcedureName = 'pr_order_tx_admin_allow_edit'

        const parameters = {
            current_uid: req.body.current_uid,
            result: {type: sql.Int, output:  true},
            msg: {type: sql.NVarChar, output:  true},
            profiler_trans_id: req.body.profiler_trans_id,
            tr_type: req.body.tr_type,
            last_mod_on: req.body.last_mod_on,
            co_id: req.body.co_id,
            axn: req.body.axn,
            url: req.body.url,
        }
        const result = await execStoredProcedure(storedProcedureName, parameters)
        console.log(result);
        res.send(result)
    } catch (err) {
        console.error(err);
        res.status(500).send("Error executing stored procedure: " + err.message);
    }
}) 

router.post("/update", async (req, res) => {
    try {
        const storedProcedureName = 'pr_order_admin_update_status'

        const parameters = {
            current_uid: req.body.current_uid,
            result: {type: sql.NVarChar, output: true},
            profiler_trans_id: req.body.profiler_trans_id,
            tr_status: req.body.tr_status,
            co_id: req.body.co_id,
            axn: req.body.axn,
            url: req.body.url,
        }

        const result = await execStoredProcedure(storedProcedureName, parameters)
        res.send(result)
        console.log(result);
    } catch(err) {
        console.error(err);
        res.status(500).send("Error executing stored procedure: " + err.message);
    }
})

module.exports = router