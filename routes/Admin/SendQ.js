const express = require("express");
const router = express.Router();
const sql = require("mssql");
const bodyParser = require("body-parser");
const mailService = require("../../tools/smtpMail");
const {
  execStoredProcedure,
  executeSelectStatement,
} = require("../../tools/dbProc");

module.exports = router;
