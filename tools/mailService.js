const nodemailer = require('nodemailer')
const mailConfig = require('../config/my-config.json')

const createTransporter = async () => {
  let mailService = mailConfig.mail.service;
  let mailHost = mailConfig.mail.host;
  let mailboxUid = mailConfig.mail.uid;
  let mailboxPwd = mailConfig.mail.pwd;
  let mailPort = mailConfig.mail.port;

  const transporter = nodemailer.createTransport({
    service: mailService,
    host: mailHost,
    port: mailPort,
    secure: false,
    auth: {
      user: mailboxUid,
      pass: mailboxPwd,
    } 
  });

  return transporter;
};

const sendEmail = async (emailOptions) => {
  try {
    const emailTransporter = await createTransporter();
    const result = await emailTransporter.sendMail(emailOptions);
    
    // Log success and messageId to console
    console.log(`Email sent successfully. MessageId: ${result.messageId}`);
  } catch (error) {
    // Log error to console
    console.error(`Error sending email: ${error.message}`);
  }
};

module.exports = {
  sendEmail,
};
