const moment = require("moment");
const path = require("path");
require("dotenv").config({ path: path.resolve(".env") });
const session = require("express-session");
const cookieParser = require("cookie-parser");
const {
  execStoredProcedure,
  executeSelectStatement,
} = require("../tools/dbProc");

let nowMoment = moment.utc();
let currentTime = nowMoment.local();
console.log(currentTime);

const sessionConfig = {
  name: "order", // name of the cookie
  secret: process.env.SECRET, // secret that make the cookie effective
  cookie: {
    maxAge: 1000 * 60 * 60, // time of the cookie (1 hour)
    secure: false, //
    httpOnly: true,
  },
  resave: false,
  saveUninitialized: true,
};
console.log(sessionConfig.secret);

// Middleware to manage session expiration and refresh
async function sessionManagement(req, res, next) {
  console.log(req.cookie);
  console.log(req.session);
  // const current = currentTime;
  // req.session._expires = moment(current).add(
  //   sessionConfig.cookie.maxAge,
  //   "milliseconds"
  // );
  // console.log(req.session);
  // res.cookie("order", sessionConfig.secret, {
  //   _expires: moment(current).add(sessionConfig.cookie.maxAge, "milliseconds"),
  // });
  // console.log(maxAge);
  // const currentTime = moment().format();
  //     const sessionStartTime = req.session.createdAt || currentTime;
  //     const maxAge = sessionConfig.cookie.maxAge;
  // if (req.session) {
  //   //) {
  //   try {
  //     if (currentTime - sessionStartTime > maxAge) {
  //       // Session has expired, clear the session and redirect to login
  //       req.session.destroy((err) => {
  //         if (err) {
  //           console.error("Error destroying session:", err);
  //         }
  //         res.clearCookie("order");
  //         return res.redirect("/");
  //       });
  //     } else {
  //       // Refresh the session by updating the creation time
  //       req.session.createdAt = currentTime;
  //     }
  //   } catch (err) {
  //     console.error("Error managing session:", err);
  //   }
  // } else {
  //   // Refresh the session by updating the creation time
  //   req.session.createdAt = currentTime;
  // }
  next();
}
// function sessionManagement(sessionConfig) {
//   return (req, res, next) => {
//     const current = currentTime;
//     req.session.cookie.expires = moment().add(
//       sessionConfig.cookie.maxAge,
//       "milliseconds"
//     );
//     console.log(req.session);
//     res.cookie("order", sessionConfig.secret, {
//       _expires: moment(current).add(
//         sessionConfig.cookie.maxAge,
//         "milliseconds"
//       ),
//     });
//     next();
//   };
// }

// Middleware to update session on user interaction
// async function sessionTouch(req, res, next) {
//   if (req.session) {
//     try {
//       await req.session.touch(); // Update the session's .maxAge property
//     } catch (err) {
//       console.error("Error updating session touch:", err);
//     }
//   }
//   next();
// }

module.exports = { sessionManagement, sessionConfig };
