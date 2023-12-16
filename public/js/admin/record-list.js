"use-strict";

function RecordList() {}

function formatDateTime(dateFormat) {
  var date = new Date(dateFormat);

  var day = date.getDate().toString().padStart(2, "0");
  var month = (date.getMonth() + 1).toString().padStart(2, "0");
  var year = date.getFullYear();

  var hours = date.getHours().toString().padStart(2, "0");
  var minutes = date.getMinutes().toString().padStart(2, "0");
  var seconds = date.getSeconds().toString().padStart(2, "0");

  var fullDate = day + "/" + month + "/" + year;
  var fullTime = hours + ":" + minutes + ":" + seconds;

  return fullDate + " at " + fullTime;
}
const urlParams = new URLSearchParams(window.location.search);
const orderId = urlParams.get("id");

RecordList.prototype.init = function () {
  console.log(orderId);
  const self = this;
  $.ajax({
    url: "http://localhost:3500/admin/order_details/get_details",
    method: "POST",
    dataType: "JSON",
    data: {
      profiler_trans_id: orderId,
    },
    success: function (response) {
      console.log(response);
      const data = response.recordsets;
      const details = $(".order-details-line");
      details.empty();
      const cloneDetails = $(".order-details-line0");

      const draft = $(".empty");
      draft.empty();

      const referenceNumber = data[0][0].doc_no;
        const date = data[0][0].created_on;
        const currStatus = data[0][0].tr_status;
        // Set the content of the reference number div
        $("#reference-number").text(`Order ${referenceNumber}`);
        $("#date").text(`${formatDateTime(date)}`);

        if (currStatus === 'S') {
          $("#curr-status").text("Current Status: Submitted");
        } else if (currStatus === 'A') {
          $("#curr-status").text("Current Status: Approved");
        } else if (currStatus === 'D') {
          $("#curr-status").text("Current Status: Draft");
        } else if (currStatus === 'R') {
          $("#curr-status").text("Current Status: Rejected");
        } else if (currStatus === 'C') {
          $("#curr-status").text("Current Status: Completed");
        } else if (currStatus === 'CX') {
          $("#curr-status").text("Current Status: Cancel");
        }

      if (response.output.result === "OK") {      
        // Calculate summary
        const summary = self.calculateSummary(data);
        console.log(summary);
        // Update HTML with summary
        $("#total-qty").text(`Total Quantity: ${summary.totalQty}`);
        $("#sub-total").text(`Sub-total: RM ${summary.subtotal.toFixed(2)}`);
        $("#tax1-total").text(`Service Charge: RM ${summary.totalTax1.toFixed(2)}`);
        $("#tax2-total").text(`SST: RM ${summary.totalTax2.toFixed(2)}`);
        $("#total-amt").text(`Total Amount: RM ${summary.totalAmount.toFixed(2)}`);

        // Populate details
        data[0].forEach(function (item) {
          const c2 = cloneDetails
            .clone()
            .removeClass("order-details-line0")
            .addClass("item-content flex-row")
            .data("data", item);

          const imagePath = item.img_url
          // Find the index of '\\images'
          const indexOfImages = imagePath.indexOf('\\images');
          
          // Slice the string from the index of '\\images'
          const slicedPath = imagePath.substring(indexOfImages);

          const imgElement = $("<img>").attr("src", slicedPath).addClass("prod-img");
          c2.find(".prod-img-con").append(imgElement);
          c2.find(".prod-name").text(item.prod_desc);
          c2.find(".qty").text(item.qty);
          c2.find(".amount").text(`RM ${item.amt}`);
          c2.find(".amount").text(`RM ${item.amt}`);

          details.append(c2);
        });
      } else {
        const errorContainer = $("<div>").addClass("error");
        const errorMessage = $("<p>").text(response.output.result);
        errorContainer.append(errorMessage);
        draft.append(errorContainer);
      }
      self.checkStatus();

      const trStatus = data[0][0].tr_status;
      self.updateSelectOptions(trStatus)
    },
  });
  $(".update-status").on("click", function () {
    self.updateStatus();
  });
};

RecordList.prototype.updateSelectOptions = function (trStatus) {
  const select = $(".status-sel");

  // Clear existing options
  select.empty();

  // Add new options based on tr_status
  if (trStatus === "A") {
    select.append('<option value="A" selected>Approved</option>');
    select.append('<option value="R">Rejected</option>');
    select.append('<option value="C">Completed</option>');
  } else if (trStatus === "R") {
    select.append('<option value="A">Approved</option>');
    select.append('<option value="R" selected>Rejected</option>');
    select.append('<option value="C">Completed</option>');
  } else if (trStatus === "C") {
    select.append('<option value="A">Approved</option>');
    select.append('<option value="R">Rejected</option>');
    select.append('<option value="C" selected>Completed</option>');
  } else {
    // Default options
    select.append('<option value="-">-Select-</option>');
    select.append('<option value="A">Approved</option>');
    select.append('<option value="R">Rejected</option>');
    select.append('<option value="C">Cancelled</option>');
  }
};

// Summary calculation function
RecordList.prototype.calculateSummary = function (data) {
  console.log(data);
  let totalQty = 0;
  let subtotal = 0;
  let totalTax1 = 0;
  let totalTax2 = 0;
  let totalAmount = 0;

  data[0].forEach((item) => {
    console.log(item);
    const test = item.qty
    const sellPrice = parseFloat(item.sell_price)
    const qty = parseInt(item.qty) || 0;
    const amt = parseFloat(item.amt) || 0;
    const taxAmt1 = parseFloat(item.tax_amt1_calc) || 0;
    const taxAmt2 = parseFloat(item.tax_amt2_calc) || 0;
    console.log(test);
    subtotal += qty * sellPrice;
    totalQty += qty;
    totalTax1 += taxAmt1;
    totalTax2 += taxAmt2;
    totalAmount += amt;
  });

  return {
    totalQty,
    subtotal,
    totalTax1,
    totalTax2,
    totalAmount,
  };
};

RecordList.prototype.checkStatus = function() {
  $.ajax({
    url: "http://localhost:3500/admin/status",
    method: "POST",
    dataType: 'JSON',
    data: {
      profiler_trans_id: orderId
    }, success: function(response) {
      const data = response.output
      console.log(data);
      if (data.result === 1) {
        console.log('The record is editable!');
      } else {
        var alertMsg = "Editing is Not Allow!!!";
        $("#popup-message").text(alertMsg);
        $("#popup-container").show();
        $(".update-status").hide()
      }
      $("#popup-close-btn").on("click", function () {
        $("#popup-container").hide();
      });
    }
  })
}

RecordList.prototype.updateStatus = function() {
  const status = $(".status-sel").val()
  console.log(status);
  $.ajax({
    url: "http://localhost:3500/admin/status/update",
    method: "POST",
    dataType: 'JSON',
    data: {
      current_uid: localStorage.getItem("a"),
      profiler_trans_id: orderId,
      tr_status: status
    }, success: function (response) {
      const data = response.output
      if (data.result === 'OK') {
        var alertMsg = "Status Updated Successful!!👍";
        $("#popup-message").text(alertMsg);
        $("#popup-container").show();
      } else {
        var alertMsg = data.result;
        $("#popup-message").text(alertMsg);
        $("#popup-container").show();
      }
      $("#popup-close-btn").on("click", function () {
        $("#popup-container").hide();
      });
    }
  })
}

//--------------------------------------//
//        Page Startup Function         //
//--------------------------------------//
$(() => {
  const recordList = new RecordList();
  recordList.init();
});
