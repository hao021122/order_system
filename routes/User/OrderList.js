const express = require("express")
const router = express.Router()
const path = require("path");
const sql = require("mssql");
const bodyParser = require("body-parser");
const {
  execStoredProcedure,
  executeSelectStatement,
} = require("../../tools/dbProc");

router.use(bodyParser.urlencoded({ extended: false }));
router.use(bodyParser.json());

router.get("/details", async (req, res) => {
    const id = req.query.id
    res.sendFile(path.join(__dirname, "../../", "views", "modules", "User", "record-list.html"))
})

router.post("/get_details", async (req, res) => {
    try {

        const storedProcedureName = "pr_order_details_list"
    
        const parameters = {
            // current_uid: req.body.current_uid,
            profiler_trans_id: req.body.profiler_trans_id
            , result: {type: sql.NVarChar, output: true}
        }
        const result = await execStoredProcedure(storedProcedureName, parameters)
        console.log(result);
        res.send(result)
    } catch (err) {
        console.error(err);
        res.status(500).send("Error executing stored procedure: " + err.message);
    }
})

module.exports = router