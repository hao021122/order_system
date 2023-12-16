const sql = require('mssql')
const path = require('path')
const {
  execStoredProcedure,
  executeSelectStatement,
} = require("../tools/dbProc");

// Logout function
const performLogout = async (sess_uid, res) => {
  try {
    const storedProcedureName = "pr_user_logout";

    const parameters = {
      sess_uid: sess_uid,
      result: { type: sql.NVarChar, output: true },
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    res.send(result);

    if (result.output.result === 'OK') {
      req.session.destroy();
    } 
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
};

const reloadCookie = () => {
  
}

const isAuthenticated = (req, res, next) => {
  // Check if the user is logged in by verifying the presence of user session data
  const gmtDate = new Date();
  console.log(req.session.userData);
  if (req.session.userData && req.session.userData.sess_uid) {
    // User is authenticated, continue to the next middleware or route

    // Convert to GMT+8:00 (Malaysia, Kuala Lumpur Standard Time)
    const gmtPlus8Date = new Date(gmtDate.getTime() + 8 * 60 * 60 * 1000); // Add 8 hours in milliseconds

    console.log("GMT Date:", gmtDate.toISOString());
    console.log("GMT+08:00 Date:", gmtPlus8Date.toISOString());

    // Log the current time if needed
    console.log("Current Time:", gmtDate.toISOString());
    next();
  } else if (gmtDate.toISOString() + req.session.cookie.originalMaxAge - req.session.cookie._expires <= 60000 ) {
    performLogout(req.session.userData.sess_uid)
  } else {
    // User is not authenticated, redirect to the login page or send an unauthorized response
    res.redirect("/")
    // res.status(401).send("Unauthorized");
  }
};

const isAuthorized = (requireRole) => {
  return (req, res, next) => {
    console.log(req.session.userData);
    const userRole = req.session.userData.userGroupId
    if (requireRole.includes(userRole)) {
      next()
    } else {
      res.sendFile(path.join(
        __dirname,
        "../",
        "views",
        "modules",
        "unauthorise.html"
      ))
    }
  }
}

module.exports = { isAuthenticated, isAuthorized };
