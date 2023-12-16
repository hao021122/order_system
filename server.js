const express = require("express");
const app = express();
const cors = require("cors");
const path = require("path");
const { isAuthenticated, isAuthorized } = require("./middleware/authMiddleware");
const session = require("express-session");
const cookieParser = require("cookie-parser");
const moment = require("moment");
const {
  execStoredProcedure,
  executeSelectStatement,
} = require("./tools/dbProc");

// Router
const addOnRouter = require("./routes/Settings/Addon");
const categoryRouter = require("./routes/Settings/Category");
const condimentRouter = require("./routes/Settings/Condiment");
const foodMenuRouter = require("./routes/Settings/FoodMenu");
const guestRouter = require("./routes/User/Guest");
const menuItemRouter = require("./routes/Settings/MenuItem");
const organizationRouter = require("./routes/Settings/Organization");
const outletProfileRouter = require("./routes/Settings/CompanyProfile");
const paymentRouter = require("./routes/Settings/Payment");
const groupRouter = require("./routes/Settings/ProductGroup");
const typeRouter = require("./routes/Settings/ProductType");
const quotationSettingRouter = require("./routes/Settings/QuotationSetting");
const requestRouter = require("./routes/Settings/Request");
const seasonRouter = require("./routes/Settings/Season");
const smtpRouter = require("./routes/Settings/Smtp");
const taxRouter = require("./routes/Settings/Tax");
const uomRouter = require("./routes/Settings/Uom");
const userRouter = require("./routes/Settings/User");

// User Side
const addRouter = require("./routes/User/Orders");
const historyRouter = require("./routes/User/History");
const userListRouter = require("./routes/User/OrderList")

// Admin
const logRouter = require("./routes/Admin/AuditLog");
const adminRouter = require("./routes/Admin/dashboard");
const updateStatusRouter = require("./routes/Admin/UpdateStatus");
const adminListRouter = require("./routes/Admin/OrderList")

// Public
const loginRouter = require("./routes/Public/Login");

const PORT = 3500;

let nowMoment = moment.utc();

let currentTime = nowMoment.local();
console.log(currentTime);

// const maxAgeValue = async () => {
//   let sess_exp;
//   const result = await executeSelectStatement(
//     `SELECT prop_value FROM tb_sys_prop WHERE prop_name = 'sess_timeout_minute'`
//   );
//   sess_exp = result[0];
//   if (sess_exp !== null && !isNaN(sess_exp)) {
//     return parseInt(sess_exp);
//   }
// };

// const a = maxAgeValue();
// console.log(a);

const sessionConfig = {
  name: process.env.NAME, // name of the cookie
  secret: process.env.SECRET, // secret that make the cookie effective
  sameSite: "true",
  cookie: {
    maxAge: 60 * 60 * 1000, // time of the cookie based on tb_sys_prop value
    secure: false, //
    httpOnly: true,
  },
  resave: false,
  saveUninitialized: true,
};

// console.log(sessionConfig.cookie.maxAge);

// async function configureSession() {
//   const maxAgeValue = await executeSelectStatement(
//     `SELECT prop_value FROM tb_sys_prop WHERE prop_name = 'sess_timeout_minute'`
//   );

//   if (maxAgeValue !== null && !isNaN(maxAgeValue)) {
//     const sessionConfig = {
//       name: "order",
//       secret: process.env.SECRET,
//       sameSite: "true",
//       cookie: {
//         maxAge: maxAgeValue * 60 * 1000,
//         secure: false,
//         httpOnly: true,
//       },
//       resave: false,
//       saveUninitialized: true,
//     };
//     console.log(sessionConfig.cookie.maxAge);
//     app.use(session(sessionConfig));
//   } else {
//     console.error("Invalid maxAgeValue");
//   }
// }

// The app.use(session(sessionConfig)) is inside
// configureSession();
app.use(cors());
app.use(session(sessionConfig));
app.use(cookieParser());

// Serve static files from the "public" directory
app.use(express.static(path.join(__dirname, "public")));

// Define a route to handle the root URL ("/")
app.get("/", (req, res) => {
  // Construct the absolute file path to the login.html file
  const loginPath = path.join(
    __dirname,
    "./",
    "views",
    "modules",
    "login.html"
  );
  // Send the login.html file as the response
  res.sendFile(loginPath);
});

app.get(
  "/admin/dashboard",
  isAuthenticated,
  isAuthorized(["E264CF57-05C5-4F11-9799-9DCA56C68012", "9EB42C04-B359-4BB7-9151-7BB3BF519AA9"]), 
  (req, res) => {
    console.log(req.session);
    const dashboardPath = path.join(
      __dirname,
      "./",
      "views",
      "modules",
      "admin",
      "dashboard.html"
    );
    res.sendFile(dashboardPath);
  }
);

app.get("/admin/order_history", 
isAuthenticated, 
isAuthorized(["E264CF57-05C5-4F11-9799-9DCA56C68012", "9EB42C04-B359-4BB7-9151-7BB3BF519AA9", "75075FC3-05F2-46F1-964D-4F2003E2A439"]), 
(req, res) => {
  const recordPath = path.join(
    __dirname,
    "./",
    "views",
    "modules",
    "admin",
    "order_record.html"
  );
  res.sendFile(recordPath);
})

app.get("/admin/report", isAuthenticated, (req, res) => {
  const reportPath = path.join(
    __dirname,
    "./",
    "views",
    "modules",
    "admin",
    "report.html"
  );
  res.sendFile(reportPath);
});

app.get("/admin/settings", isAuthenticated, isAuthorized(["E264CF57-05C5-4F11-9799-9DCA56C68012"]), (req, res) => {
  const settingsPath = path.join(
    __dirname,
    "./",
    "views",
    "modules",
    "admin",
    "settings.html"
  );
  res.sendFile(settingsPath);
});

// // Logout
// app.post("/logout", (req, res) => {
//   req.session.destroy((err) => {
//     if (err) {
//       console.log(err);
//       //return res.redirect("/home");
//     }
//     res.clearCookie("order");
//     res.redirect("/");
//   });
// });

// Backend API
// Router
app.use("/admin/addon", isAuthenticated, isAuthorized(["E264CF57-05C5-4F11-9799-9DCA56C68012"]), addOnRouter); // Addon
app.use("/admin/category", isAuthenticated, isAuthorized(["E264CF57-05C5-4F11-9799-9DCA56C68012"]), categoryRouter); // Category
app.use("/admin/condiment", isAuthenticated, isAuthorized(["E264CF57-05C5-4F11-9799-9DCA56C68012"]), condimentRouter); // Condiment
app.use("/admin/food_menu", isAuthenticated, isAuthorized(["E264CF57-05C5-4F11-9799-9DCA56C68012"]), foodMenuRouter); // Food Menu
app.use("/admin/guest", isAuthenticated, isAuthorized(["E264CF57-05C5-4F11-9799-9DCA56C68012"]), guestRouter); // Guest
app.use("/admin/menu_item", isAuthenticated, isAuthorized(["E264CF57-05C5-4F11-9799-9DCA56C68012"]), menuItemRouter); // Menu Item
app.use("/admin/organization", isAuthenticated, isAuthorized(["E264CF57-05C5-4F11-9799-9DCA56C68012"]), organizationRouter); // Organization
app.use("/admin/outlet", isAuthenticated, isAuthorized(["E264CF57-05C5-4F11-9799-9DCA56C68012"]), outletProfileRouter); // Outlet Profile
app.use("/admin/payment", isAuthenticated, isAuthorized(["E264CF57-05C5-4F11-9799-9DCA56C68012"]), paymentRouter); // Payment type
app.use("/admin/group", isAuthenticated, isAuthorized(["E264CF57-05C5-4F11-9799-9DCA56C68012"]), groupRouter); // Product Group
app.use("/admin/product_type", isAuthenticated, isAuthorized(["E264CF57-05C5-4F11-9799-9DCA56C68012"]), typeRouter); // Product Type
app.use("/admin/quotation_setting", isAuthenticated, isAuthorized(["E264CF57-05C5-4F11-9799-9DCA56C68012"]), quotationSettingRouter); // Quotation Setting
app.use("/admin/request", isAuthenticated, isAuthorized(["E264CF57-05C5-4F11-9799-9DCA56C68012"]), requestRouter); // Request
app.use("/admin/season", isAuthenticated, isAuthorized(["E264CF57-05C5-4F11-9799-9DCA56C68012"]), seasonRouter); // Season
app.use("/admin/mailbox", isAuthenticated, isAuthorized(["E264CF57-05C5-4F11-9799-9DCA56C68012"]), smtpRouter); // Mailbox
app.use("/admin/tax", isAuthenticated, isAuthorized(["E264CF57-05C5-4F11-9799-9DCA56C68012"]), taxRouter); // Tax
app.use("/admin/uom", isAuthenticated, isAuthorized(["E264CF57-05C5-4F11-9799-9DCA56C68012"]), uomRouter); // UOM
app.use("/admin/users", isAuthenticated, isAuthorized(["E264CF57-05C5-4F11-9799-9DCA56C68012"]), userRouter); // user

// User Side
app.use("/order", isAuthenticated, addRouter); // Handle Order
app.use("/order_history", isAuthenticated, historyRouter); // Handle Order History
app.use("/order_details", isAuthenticated, userListRouter)

// Admin Side
app.use("/admin/audit_log", isAuthenticated, isAuthorized(["E264CF57-05C5-4F11-9799-9DCA56C68012"]), logRouter);
app.use("/admin/order_record", isAuthenticated, isAuthorized(["E264CF57-05C5-4F11-9799-9DCA56C68012", "9EB42C04-B359-4BB7-9151-7BB3BF519AA9", "75075FC3-05F2-46F1-964D-4F2003E2A439"]), adminRouter);
app.use("/admin/status", isAuthenticated, isAuthorized(["E264CF57-05C5-4F11-9799-9DCA56C68012", "9EB42C04-B359-4BB7-9151-7BB3BF519AA9", "75075FC3-05F2-46F1-964D-4F2003E2A439"]), updateStatusRouter);
app.use("/admin/order_details", isAuthenticated, isAuthorized(["E264CF57-05C5-4F11-9799-9DCA56C68012", "9EB42C04-B359-4BB7-9151-7BB3BF519AA9"]), adminListRouter)

// Public
app.use("/order_auth", loginRouter);

// Error page (404)
app.use((req, res) => {
  res
    .status(404)
    .sendFile(path.join(__dirname, "./", "views", "modules", "error.html"));
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
  const portDate = moment().format();
  console.log(portDate);
});
