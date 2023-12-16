const express = require("express");
const router = express.Router();
const bodyParser = require("body-parser");
const path = require("path");
const {
  execStoredProcedure,
  executeSelectStatement,
} = require("../../tools/dbProc");

router.use(bodyParser.urlencoded({ extended: false }));
router.use(bodyParser.json());

router.post("/list", async (req, res) => {
  try {
    const storedProcedureName = "pr_profiler_trans_list";

    const parameters = {
      current_uid: req.body.current_uid,
      tr_type: req.body.tr_type,
      start_dt: req.body.start_dt,
      end_dt: req.body.end_dt,
      doc_no: req.body.doc_no,
      profiler_trans_id: req.body.profiler_trans_id,
      co_id: req.body.co_id,
      axn: req.body.axn,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    res.send(result);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

module.exports = router;
