const express = require("express");
const router = express.Router();
const sql = require("mssql");
const bodyParser = require("body-parser");
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const {
  execStoredProcedure
} = require("../../tools/dbProc");

router.use(bodyParser.urlencoded({ extended: false }));
router.use(bodyParser.json());

// Create a storage instance for multer
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const targetFolder = "./public/images/user_upload";

    // Check if the target folder exists
    if (!fs.existsSync(targetFolder)) {
      // Create the target folder if it doesn't exist
      fs.mkdirSync(targetFolder, { recursive: true });
    }

    cb(null, targetFolder);
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});

const upload = multer({ storage: storage });
//

router.get("/", (req, res) => {
  res.sendFile(
    path.join(
      __dirname,
      "../../",
      "views",
      "modules",
      "settings",
      "set-menu-item.html"
    )
  );
});

router.get("/add_product", (req, res) => {
  res.sendFile(
    path.join(
      __dirname,
      "../../",
      "views",
      "modules",
      "settings",
      "add-product.html"
    )
  );
})

// Create
router.post("/save", upload.single("img_url"), async (req, res) => {
  try {
    const storedProcedureName1 = "pr_prod_code_save";

    const parameters1 = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      prod_id:
        req.body.prod_id === null || "" || undefined
          ? null
          : {
              value: req.body.prod_id,
              type: sql.UniqueIdentifier,
              output: true,
            },
      prod_cat_id: req.body.prod_cat_id,
      prod_code: req.body.prod_code,
      prod_desc: req.body.prod_desc,
      //prod_size: req.body.prod_size,
      //prod_color: req.body.prod_color,
      barcode: req.body.barcode == "" ? null : req.body.barcode,
      price: req.body.price == "" ? null : req.body.price,
      cost: req.body.cost == "" ? null : req.body.cost,
      uom_id: req.body.uom_id,
      prod_type_id: req.body.prod_type_id,
      prod_group_id: req.body.prod_group_id,
      //parent_prod_id: req.body.parent_prod_id,
      is_in_use: req.body.is_in_use,
      //is_global: req.body.is_global,
      //max_allow_on_same_day: req.body.max_allow_on_same_day,
      img_url: req.file ? req.file.path : null,
      tax_code1: req.body.tax_code1 == "" ? null : req.body.tax_code1,
      amt_inclusive_tax1: req.body.amt_inclusive_tax1,
      tax_code2: req.body.tax_code2 == "" ? null : req.body.tax_code2,
      amt_inclusive_tax2: req.body.amt_inclusive_tax2,
      calc_tax2_after_add_tax1: req.body.calc_tax_after_add_tax1,
      start_dt: req.body.start_dt,
      end_dt: req.body.end_dt,
      prepare_time: req.body.prepare_time == "" ? null : req.body.prepare_time,
      //sell_on_web: req.body.sell_on_web,
      //sell_in_outlet: req.body.sell_in_outlet,
      prod_desc2: req.body.prod_desc2 == "" ? null : req.body.prod_desc2,
      //keep_daily_avail: req.body.keep_daily_avail,
      co_id: req.body.co_id,
      axn: req.body.axn,
      url: req.body.url,
    };
    console.log(parameters1.img_url);
    console.log(parameters1);

    const result1 = await execStoredProcedure(
      storedProcedureName1,
      parameters1
    );
    console.log(result1.output.result);
    console.log(result1.output.prod_id);

    const response = {
      data: {
        result: result1.output.result,
        prod_id: result1.output.prod_id,
        modified_on: new Date().toISOString(), // Current date
        modified_by: req.body.current_uid,
      },
      msg: result1.output.result,
    };

    if (result1.output.result !== "OK") {
      return;
    }

    const storedProcedureName2 = "pr_prod_addon_save";

    const addonIds = JSON.parse(req.body.addon_id);
    const requestGroupCodes = JSON.parse(req.body.request_group_code);
    const result2ArrayByAddon = []; // Store the results of each iteration for addons
    const result2ArrayByRequestGroup = []; // Store the results of each iteration for request groups

    if (Array.isArray(addonIds)) {
      for (const addonId of addonIds) {
        const addonParameters = {
          current_uid: req.body.current_uid,
          result: { type: sql.NVarChar, output: true },
          prod_addon_id: { type: sql.UniqueIdentifier, output: true },
          prod_id: result1.output.prod_id,
          condiment_id: null,
          request_group_code: null,
          addon_id: addonId,
          co_id: req.body.co_id,
          axn: req.body.axn,
          url: req.body.url,
        };

        const addonResult = await execStoredProcedure(
          storedProcedureName2,
          addonParameters
        );

        console.log(addonResult.output.result);
        result2ArrayByAddon.push(addonResult); // Add the result to the array
      }
    } else {
      console.error("addon_id is not an array");
    }

    if (Array.isArray(requestGroupCodes)) {
      for (const requestGroupCode of requestGroupCodes) {
        const requestGroupParameters = {
          current_uid: req.body.current_uid,
          result: { type: sql.NVarChar, output: true },
          prod_addon_id: { type: sql.UniqueIdentifier, output: true },
          prod_id: result1.output.prod_id,
          condiment_id: null,
          request_group_code: requestGroupCode,
          addon_id: null,
          co_id: req.body.co_id,
          axn: req.body.axn,
          url: req.body.url,
        };

        const requestGroupResult = await execStoredProcedure(
          storedProcedureName2,
          requestGroupParameters
        );

        console.log(requestGroupResult.output.result);
        result2ArrayByRequestGroup.push(requestGroupResult); // Add the result to the array
      }
    } else {
      console.error("request_group_code is not an array");
    }

    res.send({
      //result1,
      response,
      result2ByAddon: result2ArrayByAddon,
      result2ByRequestGroup: result2ArrayByRequestGroup,
    });
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

// List
router.post("/list", async (req, res) => {
  try {
    const storedProcedureName = "pr_prod_code_list";

    const parameters = {
      current_uid: req.body.current_uid,
      prod_id: req.body.prod_id,
      prod_type_id: req.body.prod_type_id,
      prod_cat_id: req.body.prod_cat_id,
      prod_group_id: req.body.prod_group_id,
      prod_code: req.body.prod_code,
      prod_desc: req.body.prod_desc,
      barcode: req.body.barcode,
      is_in_use: req.body.is_in_use,
      co_id: req.body.co_id,
      axn: req.body.axn,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result.recordsets);
    res.send(result);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

module.exports = router;
