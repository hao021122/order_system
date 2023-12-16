const express = require("express");
const router = express.Router();
const sql = require("mssql");
const bodyParser = require("body-parser");
const bcrypt = require("bcrypt");
const useragent = require("useragent");
const path = require("path");
const {
  execStoredProcedure,
  executeSelectStatement,
} = require("../../tools/dbProc");

router.use(bodyParser.urlencoded({ extended: false }));
router.use(bodyParser.json());

router.post("/auth", async (req, res) => {
  try {
    const userAgentHeader = req.headers["user-agent"];
    const userAgent = useragent.parse(userAgentHeader);

    let username = req.body.uid;

    const storedProcedureName = "pr_user_login";

    // Assuming you have already fetched the stored hash for the user from the database
    const resultPwd = await executeSelectStatement(
      `SELECT pwd FROM tb_users WHERE login_id = '${username}'`
    );

    console.log(resultPwd);

    if (!resultPwd || resultPwd.length === 0 || resultPwd[0] === null) {
      return res.status(401).json({
        error: "Invalid User",
      });
    }

    hashPwd = resultPwd[0][0];

    // Comparing the provided password with the stored hash directly
    const isPasswordMatch = await bcrypt.compare(req.body.pwd, hashPwd);

    if (!isPasswordMatch) {
      return res.status(401).json({
        error: "Invalid Password",
      });
    }

    console.log(isPasswordMatch);
    const parameters = {
      uid: username,
      pwd: hashPwd, // Use the stored hash here
      verify_pwd: req.body.verify_pwd,
      // IP address
      user_host: req.headers["x-forwarded-for"] || req.socket.remoteAddress,
      // Browser Information
      browser_name: userAgent.family,
      os_platform: userAgent.os.family,
      browser_version: userAgent.toVersion(),
      user_agent: req.headers["user-agent"],
      // Output
      result: { type: sql.NVarChar, output: true },
      sess_uid: { type: sql.UniqueIdentifier, output: true },
      login_id: { type: sql.NVarChar, output: true },
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result);

    const result2 = await executeSelectStatement(
      `SELECT * FROM dbo.fn_get_user_info('${result.output.login_id}', dbo.fn_empty_guid(), '${result.output.sess_uid}')`
    );
    console.log(result2);
    const userGroupId = result2[0][4];

    if (result.output.result === 'OK') {
      // set the session of user 
      req.session.userData = {
        sess_uid: result.output.sess_uid,
        cur_id: result.output.login_id,
        userGroupId: userGroupId
      };
      console.log(req.session.userData);
    } 
    
    res.send({ result, result2: result2[0][4] });

    // if (req.user.userGroupId !== "75075FC3-05F2-46F1-964D-4F2003E2A439") {
    //   res.sendFile(
    //     path.join(
    //       __dirname,
    //       "../../",
    //       "views",
    //       "modules",
    //       "admin",
    //       "dashboard.html"
    //     )
    //   );
    // } else {
    //   res.sendFile(
    //     path.join(__dirname, "../../", "views", "modules", "user", "home.html")
    //   );
    // }
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

// Logout
router.post("/logout", async (req, res) => {
  try {
    const storedProcedureName = "pr_user_logout";

    const parameters = {
      sess_uid: req.body.sess_uid,
      result: { type: sql.NVarChar, output: true },
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    res.send(result);

    const loginHtmlPath = path.join(
      __dirname,
      "../../",
      "views",
      "modules",
      "login.html"
    );
    if (result.output.result === 'OK') {
      req.session.destroy();
    } 
    res.sendFile(loginHtmlPath);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

// Logout All
router.post("/logout_all", async (req, res) => {
  try {
    const storedProcedureName = "pr_user_logout_all";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      user_id: req.body.user_id,
    };
    const result = await execStoredProcedure(storedProcedureName, parameters);
    res.send(result);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

module.exports = router;
