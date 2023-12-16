const express = require("express");
const router = express.Router();
const path = require("path");
const sql = require("mssql");
const bodyParser = require("body-parser");
const {
  execStoredProcedure,
  executeSelectStatement,
} = require("../../tools/dbProc");
const mail = require('../../config/my-config.json')
const {sendEmail} = require("../../tools/mailService");

router.use(bodyParser.urlencoded({ extended: false }));
router.use(bodyParser.json());

// User Home Page
router.get("/", (req, res) => {
  res.sendFile(
    path.join(__dirname, "../../", "views", "modules", "user", "home.html")
  );
});

// User Cart Page
router.get("/cart", (req, res) => {
  res.sendFile(
    path.join(__dirname, "../../", "views", "modules", "user", "cart.html")
  );
});

// user Orderr History Page
router.get("/order_history", (req, res) => {
  res.sendFile(
    path.join(__dirname, "../../", "views", "modules", "user", "history.html")
  );
});

// Menu Item List
router.post("/menu_list", async (req, res) => {
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

// Category List
router.post("/cat_list", async (req, res) => {
  try {
    const storedProcedureName = "pr_prod_cat_list";

    const parameters = {
      current_uid: req.body.current_uid,
      prod_cat_id: req.body.prod_cat_id,
      is_in_use: req.body.is_in_use,
      co_id: req.body.co_id,
      axn: req.body.axn, // setup, last-mod-on or null
      my_role_id: req.body.my_role_id,
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

// New Trans
router.post("/new_id", async (req, res) => {
  try {
    const storedProcedureName = "pr_order_tx_new";
    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      profiler_trans_id:
        req.body.profiler_trans_id === null
          ? { type: sql.UniqueIdentifier, output: true }
          : {
              value: req.body.profiler_trans_id,
              type: sql.UniqueIdentifier,
              output: true,
            },
      co_id: req.body.co_id,
      axn: req.body.axn,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result.output.profiler_trans_id);
    console.log(result.output.profiler_trans_id.length);
    res.send(result);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

router.post("/new_q", async (req, res) => {
  try {
    const storedProcedureName = "pr_sys_gen_new_doc_no";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      doc_no:
        req.body.doc_no === null
          ? { type: sql.NVarChar, output: true }
          : { value: req.body.doc_no, type: sql.NVarChar, output: true },
      co_id: req.body.co_id,
      doc_group: req.body.doc_group,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result.output.doc_no);
    res.send(result);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

router.post("/get_doc_no_pt_id", async (req, res) => {
  try {
    const storedProcedureName = "pr_order_doc_no_pt_id_list";

    const parameters = {
      current_uid: req.body.current_uid,
      doc_no:
        req.body.doc_no === null
          ? { type: sql.NVarChar, output: true }
          : { value: req.body.doc_no, type: sql.NVarChar, output: true },
      profiler_trans_id:
        req.body.profiler_trans_id === null
          ? { type: sql.UniqueIdentifier, output: true }
          : {
              value: req.body.profiler_trans_id,
              type: sql.UniqueIdentifier,
              output: true,
            },
      co_id: req.body.co_id,
      axn: req.body.axn,
      url: req.body.url,
      is_debug: req.body.is_debug,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    res.send(result);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

router.post("/add_line", async (req, res) => {
  try {
    const storedProcedureName = "pr_order_tx_add_line";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      tr_id:
        req.body.tr_id === null
          ? { type: sql.UniqueIdentifier, output: true }
          : { value: req.body.tr_id, type: sql.UniqueIdentifier, output: true },
      tr_date: req.body.tr_date,
      tr_type: req.body.tr_type,
      doc_no: req.body.doc_no,
      profiler_trans_id: req.body.profiler_trans_id,
      prod_id: req.body.prod_id,
      qty: req.body.qty,
      cost: req.body.cost,
      sell_price: req.body.sell_price,
      amt: req.body.amt,
      addon_amt: req.body.addon_amt,
      profile_id: req.body.profile_id,
      discount_amt: req.body.discount_amt,
      discount_pct: req.body.discount_pct,
      //discount_id: req.body.discount_id,
      //disc_total_calc: req.body.disc_total_calc,
      is_ready: req.body.is_ready,
      remarks: req.body.remarks,
      c1: req.body.c1,
      c2: req.body.c2,
      c3: req.body.c3,
      coupon_no: req.body.coupon_no,
      coupon_id: req.body.coupon_id,
      co_id: req.body.co_id,
      axn: req.body.axn,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    const outputTrId = result.output.tr_id

    if (result.output.result !== "OK") {
      return;
    }

    const storedProcedureName2 = "pr_order_tx_addon_set";

    const addonIds = JSON.parse(req.body.addon_id);
    const requestIds = JSON.parse(req.body.request_id);
    const resultArrayByAddon = []; // Store the results of each iteration for addons
    const resultArrayByRequest = []; // Store the results of each iteration for requests

    if (Array.isArray(addonIds)) {
      for (const addonId of addonIds) {
        const addonsParameters = {
          current_uid: req.body.current_uid,
          profiler_trans_id: req.body.profiler_trans_id,
          tr_id: outputTrId,
          condiment_id: null,
          request_id: null, // Set request_id to null for addons
          remarks: req.body.remarks,
          addon_id: addonId,
          co_id: req.body.co_id,
          axn: req.body.axn,
          url: req.body.url,
        };

        const addonResult = await execStoredProcedure(storedProcedureName2, addonsParameters);
        console.log(addonResult);
        resultArrayByAddon.push(addonResult); // Add the result to the array
      }
    } else {
      console.error("addon_id is not an array");
    }

    if (Array.isArray(requestIds)) {
      for (const requestId of requestIds) {
        const requestParameters = {
          current_uid: req.body.current_uid,
          profiler_trans_id: req.body.profiler_trans_id,
          tr_id: outputTrId,
          condiment_id: null, // Set condiment_id to null for requests
          request_id: requestId,
          remarks: req.body.remarks,
          addon_id: null,
          co_id: req.body.co_id,
          axn: req.body.axn,
          url: req.body.url,
        };

        const requestResult = await execStoredProcedure(storedProcedureName2, requestParameters);
        console.log(requestResult);
        resultArrayByRequest.push(requestResult); // Add the result to the array
      }
    } else {
      console.error("request_id is not an array");
    }

    res.send({
      result,
      resultArrayByAddon,
      resultArrayByRequest,
    });
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

router.post("/save", async (req, res) => {
  let emailContent;

  try {
    const storedProcedureName = "pr_order_tx_checkout";
    const parameters = {
      current_uid: req.body.current_uid,
      msg: { type: sql.Int, output: true },
      send_to: { type:sql.NVarChar, output: true },
      tr_type: req.body.tr_type,
      tr_date: req.body.tr_date,
      tr_id: req.body.tr_id,
      profiler_trans_id: req.body.profiler_trans_id,
      doc_no: req.body.doc_no,
      co_id: req.body.co_id,
      axn: req.body.axn,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);

    try {
      const result = await executeSelectStatement(`
      SELECT 
          pc.img_url, st.doc_no, pc.prod_desc, st.qty, st.amt 
          FROM tb_stock_trans st
          INNER JOIN tb_prod_code pc ON pc.prod_id = st.prod_id
          WHERE profiler_trans_id = '${req.body.profiler_trans_id}'
      `);
      console.log("Result: " + result);

      result.forEach((row) => {
        emailContent =`
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Order Details | Ref-No: ${row[1]}</title>
        </head>
        <body style="font-family: Arial, sans-serif;">
        <h3>PLease Check Your Order and Confim the Order by Whatsapp Link below</h3>
        <a aria-label="Chat on WhatsApp" href="https://wa.me/189551882"> <img alt="Chat on WhatsApp" src="WhatsAppButtonGreenLarge.svg" />
        <a />
            <table style="width: 100%; border-collapse: collapse; margin-top: 20px; padding: 20px;">
                <thead style="background-color: #4caf50;">
                    <tr>
                        <td style="border: 1px solid #dddddd; text-align: center; padding: 8px; background-color: #f2f2f2;">Ref #</td>
                        <td style="border: 1px solid #dddddd; text-align: center; padding: 8px; background-color: #f2f2f2;">Product Name</td>
                        <td style="border: 1px solid #dddddd; text-align: center; padding: 8px; background-color: #f2f2f2;">Quantity</td>
                        <td style="border: 1px solid #dddddd; text-align: center; padding: 8px; background-color: #f2f2f2;">Amount</td>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td style="border: 1px solid #dddddd; text-align: center; padding: 8px;">${row[1]}</td>
                        <td style="border: 1px solid #dddddd; text-align: center; padding: 8px;">${row[2]}</td>
                        <td style="border: 1px solid #dddddd; text-align: center; padding: 8px;">${row[3]}</td>
                        <td style="border: 1px solid #dddddd; text-align: center; padding: 8px;">RM ${row[4]}</td>
                    </tr>
                </tbody>
            </table>
        </body>
        
        `;
      });

      console.log(emailContent);
    } catch (err) {
      console.error(err);
      //res.status(500).send('Error executing stored procedure: ' + err.message);
    }

    res.send(result);
    console.log(result);
    console.log(result.recordsets[1]);
    console.log(result.recordsets[1][0].result);

    if (result.output.msg === 1) {
      const emailOptions = {
        from: mail.mail.uid,
        to: result.output.send_to,
        subject: `Order Confirmation Letter`,
        html: `${emailContent}`,
      };

      await sendEmail(emailOptions);
    } else {
      console.log('Email not sent out!!');
      return;
    }
  } catch (err) {
    console.error(err);
    res.status(500).send('Error executing stored procedure: ' + err.message);
  }
});


router.post("/delete_line", async (req, res) => {
  try {
    const storedProcedureName = "pr_order_tx_delete_line";

    const parameters = {
      current_uid: req.body.current_uid,
      result: { type: sql.NVarChar, output: true },
      profiler_trans_id: req.body.profiler_trans_id,
      tr_id: req.body.tr_id,
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

router.post("/addon_remove", async (req, res) => {
  try {
    const storedProcedureName = "pr_order_tx_addon_remove";

    const parameters = {
      current_uid: req.body.current_uid,
      sess_id: req.body.sess_id,
      profiler_trans_id: req.body.profiler_trans_id,
      trans_addon_id: req.body.trans_addon_id,
      remarks: req.body.remarks,
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

router.post("/cart_list", async (req, res) => {
  try {
    const storedProcedureName = "pr_order_cart_list";

    const parameters = {
      current_uid: req.body.current_uid,
      doc_no: req.body.doc_no,
      profiler_trans_id: req.body.profiler_trans_id,
      co_id: req.body.co_id,
      axn: req.body.axn,
      url: req.body.url,
    };

    const result = await execStoredProcedure(storedProcedureName, parameters);
    console.log(result);
    res.send(result);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error executing stored procedure: " + err.message);
  }
});

module.exports = router;
