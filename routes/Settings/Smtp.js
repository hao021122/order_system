const express = require("express");
const router = express.Router();
const path = require("path");
const sql = require("mssql");
const bodyParser = require("body-parser");
const nodemailer = require("nodemailer");
const bcrypt = require("bcrypt");

const {
  execStoredProcedure,
  executeSelectStatement,
} = require("../../tools/dbProc");

router.use(bodyParser.urlencoded({ extended: true }));
router.use(bodyParser.json());

// let transporter = nodemailer.createTransport({
//   host: 'smtp.gmail.com',
//   port: 587,
//   secure: false,
//   auth: {
//       user: 'your-email@gmail.com',
//       pass: 'your-password'
//   }
// });

// let mailOptions = {
//   from: 'your-email@gmail.com',
//   to: 'recipient-email@example.com',
//   subject: 'Test Email from Node.js',
//   text: 'This is a test email sent from Node.js.',
//   html: '<p>This is a test email sent from <b>Node.js</b>.</p>'
// };

// transporter.sendMail(mailOptions, function(error, info){
//   if (error) {
//       console.log(error);
//   } else {
//       console.log('Email sent: ' + info.response);
//   }
// });

router.get("/", (req, res) => {
  res.sendFile(
    path.join(
      __dirname,
      "../../",
      "views",
      "modules",
      "settings",
      "set-mailbox.html"
    )
  );
});

router.post("/save", async (req, res) => {
  try {
    const storedProcedureName = "pr_settings_server_save";

    const saltRounds = 13;
    const { smtp_mailbox_uid, smtp_mailbox_pwd } = req.body;
    console.log({ smtp_mailbox_uid, smtp_mailbox_pwd });
    // // Hash the password using bcrypt
    const hashedEmail = await bcrypt.hash(smtp_mailbox_uid, saltRounds);
    const hashedPassword = await bcrypt.hash(smtp_mailbox_pwd, saltRounds);

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      co_row_guid: req.body.co_row_guid,
      smtp_server: req.body.smtp_server,
      smtp_port: req.body.smtp_port,
      smtp_mailbox_uid: hashedEmail,
      smtp_mailbox_pwd: hashedPassword,
      smtp_use_ssl: req.body.smtp_use_ssl,
      smtp_disable_service: req.body.smtp_disable_service,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result);
    console.log(result.output.result);
    res.send(result);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

router.post("/list", async (req, res) => {
  try {
    const storedProcedureName = "pr_settings_server_load";

    const parameters = {
      current_uid: req.body.current_uid,
      co_row_guid: req.body.co_row_guid,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result.recordsets);
    console.log(result.recordsets[0][0].smtp_server);
    res.send(result);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

module.exports = router;
