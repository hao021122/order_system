const nodemailer = require("nodemailer");
const bcrypt = require("bcrypt");
const { execStoredProcedure } = require("./dbProc");

const sendMail = async () => {
  let smtpServer;
  let smtpPort;
  let smtpMailBox;
  let smtpPwd;
  try {
    const storedProcedureName = "pr_settings_server_load";

    const parameters = {
      current_uid: null,
      co_row_guid: null,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result);
    const smtpConfig = result.recordsets[0][0];
    smtpServer = smtpConfig.smtp_server;
    smtpPort = smtpConfig.smtp_port;
    smtpMailBox = smtpConfig.smtp_mailbox_uid;
    smtpPwd = smtpConfig.smtp_mailbox_pwd;

    const plainSmtpUid = smtpConfig.smtp_mailbox_uid;
    const plainSmtpPwd = smtpConfig.smtp_mailbox_pwd;

    const isUidMatch = await bcrypt.compare(plainSmtpUid, hashedSmtpUid);
    const isPasswordMatch = await bcrypt.compare(plainSmtpPwd, hashedSmtpPwd);

    // Create a Nodemailer transporter using the SMTP configuration
    const transporter = nodemailer.createTransport({
      host: smtpServer,
      port: smtpPort,
      secure: true,
      auth: {
        user: await bcrypt.compare(plainSmtpUid, smtpMailBox),
        pass: await bcrypt.compare(plainSmtpPwd, smtpPwd),
      },
    });

    const mailOptions = {
      from: smtpMailBox,
      to: "chinleehao@gmail.com",
      subject: "Test Email",
      text: "This is a test email.",
    };
    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        console.error(error);
      } else {
        console.log("Email sent: " + info.response);
      }
    });
  } catch (err) {
    throw err;
  }
};
module.exports = { sendMail };
