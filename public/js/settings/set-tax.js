"use strict";

function SetTax() {
  this.currItem = { item: null, data: {} };
  this.taxId = undefined;
}

const backButton = document.querySelector(".btn-back0");

// Add event listener to the button
backButton.addEventListener("click", function () {
  // Navigate to settings.html
  window.location.href = "/admin/settings";
});

function toggleCheckbox(checkbox) {
  $(checkbox).toggleClass("btn-checkbox btn-checkbox0");
}

// Format Date
function formatDate(dateFormat) {
  var date = new Date(dateFormat);

  var day = date.getDate().toString().padStart(2, "0");
  var month = (date.getMonth() + 1).toString().padStart(2, "0");
  var year = date.getFullYear();

  var fullDate = year + "-" + month + "-" + day;

  return fullDate;
}

SetTax.prototype.handleTaxItemFilter = function () {
  const fields = $(".search-description").val().toUpperCase();

  $(".item-content").each(function () {
    const name = $(this).find(".tax-code").text().toUpperCase();
    $(this).toggle(name.includes(fields));
  });
};

SetTax.prototype.init = function () {
  const self = this;
  $.ajax({
    url: "http://localhost:3500/admin/tax/list",
    method: "POST",
    dataType: "json",
    data: {
      axn: "setup",
    },
    success: function (response) {
      console.log(response);
      const data = response.recordsets;
      console.log(data);
      const taxItem = $(".item-list");
      taxItem.empty();
      const cloneTaxItem = $(".tax-item0");

      data.forEach(function (itemArray) {
        itemArray.forEach(function (item) {
          const c2 = cloneTaxItem
            .clone()
            .removeClass("tax-item0")
            .addClass("item-content")
            .data("data", item);
          console.table(item);

          c2.find(".tax-code").text(item.tax_code);
          c2.find(".modified-on").text(formatDate(item.modified_on));
          c2.find(".modified-by").text(item.modified_by);

          taxItem.append(c2);
        });

        taxItem.on(
          "click",
          ".item-content",
          self.handleTaxItemClick.bind(self)
        );
        taxItem.on("click", ".btn-delete", self.handleTaxItemRemove.bind(self));
      });
    },
    error: function () {
      console.log("An error has occurred.");
    },
  });

  $(".search-description").on("keyup", function () {
    self.handleTaxItemFilter();
  });

  $(".btn-add").on("click", function () {
    self.resetInputFields();
  });

  $(".btn-save").on("click", function () {
    self.handleTaxItemSave();
  });
};

SetTax.prototype.handleTaxItemClick = function (e) {
  console.log(11);
  const item = $(e.currentTarget).closest(".item-content");
  const data = item.data("data");
  console.log(data);
  this.currItem = { item, data };

  $(".tax-id-input").val(data.tax_id);
  $(".tax-code-input").val(data.tax_code);
  $(".tax-desc-input").val(data.tax_desc);
  $(".start-dt-input").val(formatDate(data.start_dt));
  $(".end-dt-input").val(formatDate(data.end_dt));
  $(".tax-pct-input").val(data.tax_pct);
  $(".tax-amt-input").val(data.tax_amt);
  $(".display-seq-input").val(data.display_seq);
  var isCheckboxActive = data.is_in_use === 1;
  $(".is-active-input")
    .toggleClass("btn-checkbox", isCheckboxActive)
    .toggleClass("btn-checkbox0", !isCheckboxActive);
};

// $.ajax({
//   url: "http://localhost:3500/tax", // Update the URL according to your backend endpoint
//   method: "POST",
//   dataType: "json",
//   data: {
//     axn: "setup",
//   },
//   success: function (response) {
//     // Handle the successful response from the backend
//     console.log(response);
//     console.log(response.recordsets);

//     // Update the UI with the retrieved data
//     var itemList = $(".item-list");
//     var content = response.recordsets;
//     var data = JSON.stringify(content);
//     console.log(data);
//     // Clear the existing content in the item list
//     // itemList.html(data);

//     // Iterate over the retrieved taxs and generate HTML for each tax
//     content.forEach(function (taxArray) {
//       taxArray.forEach(function (tax) {
//         var taxItem = $('<div class="tax-item"></div>');

//         // Store the tax ID as a data attribute on the tax item
//         taxItem.data("data", tax);
//         console.log(tax);
//         // Create and append the UI elements for the desired data fields
//         // $(
//         //   '<div class="tax-id" style="display:none;">' + tax.tax_id + "</div>"
//         // ).appendTo(taxItem);
//         // $(
//         //   '<div class="tax-code" style="display:none;">' + tax.tax_code + "</div>"
//         // ).appendTo(taxItem);
//         $('<div class="tax-description">' + tax.tax_desc + "</div>").appendTo(
//           taxItem
//         );
//         // $(
//         //   '<div class="tax-effective-form" style="display:none;">' +
//         //     tax.start_dt +
//         //     "</div>"
//         // ).appendTo(taxItem);
//         // $(
//         //   '<div class="tax-effective-to" style="display:none;">' +
//         //     tax.end_dt +
//         //     "</div>"
//         // ).appendTo(taxItem);
//         // $(
//         //   '<div class="tax-pct" style="display:none;">' + tax.tax_pct + "</div>"
//         // ).appendTo(taxItem);
//         // $(
//         //   '<div class="tax-amt" style="display:none;">' +
//         //     (tax.tax_amt !== null ? tax.tax_amt : "") +
//         //     "</div>"
//         // ).appendTo(taxItem);
//         // $(
//         //   '<div class="tax-display-seq" style="display:none;">' +
//         //     tax.display_seq +
//         //     "</div>"
//         // ).appendTo(taxItem);
//         $(
//           '<div class="modified-on">' + formatDate(tax.modified_on) + "</div>"
//         ).appendTo(taxItem);
//         $('<div class="modified-by">' + tax.modified_by + "</div>").appendTo(
//           taxItem
//         );
//         // $(
//         //   '<div class="isActive" style="display:none;">' +
//         //     tax.is_in_use +
//         //     "</div>"
//         // ).appendTo(taxItem);

//         // Add more UI elements as needed

//         // Append the tax item to the item list
//         itemList.append(taxItem);
//         console.log(taxItem);
//       });
//     });
//   },
//   error: function (xhr, status, error) {
//     // Handle any errors that occurred during the tax
//     console.error(error);
//   },
// });

// $(document).on("click", ".tax-item", function () {
//   var c0 = $(this).data("data");
//   console.log(c0);

//   // Get the clicked addon's content
//   var taxId = c0.tax_id;
//   var isActive = c0.is_in_use;

//   // Set the content in the HTML input tags
//   $(".tax-id-input").val(taxId);
//   $(".code-input").val(c0.tax_code);
//   $(".desc-input").val(c0.tax_desc);
//   $(".start-dt-input").val(formatDate(c0.start_dt));
//   $(".end-dt-input").val(formatDate(c0.end_dt));
//   $(".tax-pct-input").val(c0.tax_pct);
//   $(".tax-amt-input").val(c0.tax_amt);
//   $(".display-seq-input").val(c0.display_seq);
//   // Set the active class based on the isActive value
//   var isCheckboxActive = isActive === 1;
//   $(".is-active-input").toggleClass("btn-checkbox", isCheckboxActive);
//   $(".is-active-input").toggleClass("btn-checkbox0", !isCheckboxActive);
// });

// $(document).on("click", ".btn-add", function (e) {
//   e.preventDefault();

//   // Retrieve the input values
//   $(".tax-id-input").val("");
//   $(".code-input").val("");
//   $(".desc-input").val("");
//   $(".start-dt-input").val("");
//   $(".end-dt-input").val("");
//   $(".tax-pct-input").val("");
//   $(".tax-amt-input").val("");
//   $(".display-seq-input").val("");
//   $(".is-active-input").removeClass("btn-checkbox");
//   $(".is-active-input").addClass("btn-checkbox0");
// });

SetTax.prototype.resetInputFields = function () {
  $(
    ".tax-id-input, .tax-code-input, .tax-desc-input, .start-dt-input, .end-dt-input, .tax-pct-input, .tax-amt-input, .display-seq-input"
  ).val("");
  $(".is-active-input").removeClass("btn-checkbox");
  $(".is-active-input").addClass("btn-checkbox0");
  this.currItem = { item: null, data: {} };
};

SetTax.prototype.handleTaxItemSave = function () {
  const idInput = $(".tax-id-input");
  const codeInput = $(".tax-code-input");
  const descInput = $(".tax-desc-input");
  const startDtInput = $(".start-dt-input");
  const endDtInput = $(".end-dt-input");
  const taxPctInput = $(".tax-pct-input");
  const taxAmtInput = $(".tax-amt-input");
  const displaySeqInput = $(".display-seq-input");
  const isActive = $(".is-active-input").hasClass("btn-checkbox") ? "1" : "0";

  const ct = $(".tax-item0");
  const taxList = $(".item-list");
  const self = this;

  const data = {
    current_uid: sessionStorage.getItem("a"),
    tax_id: idInput.val() !== "" ? idInput.val() : undefined,
    tax_code: codeInput.val(),
    tax_desc: descInput.val(),
    start_dt: startDtInput.val(),
    end_dt: endDtInput.val(),
    tax_pct: parseInt(taxPctInput.val()),
    tax_amt: parseInt(taxAmtInput.val()),
    display_seq: displaySeqInput.val(),
    is_in_use: isActive,
  };

  console.log(data.tax_id);

  const requestData = {
    current_uid: data.current_uid,
    tax_id: data.tax_id,
    tax_code: data.tax_code,
    tax_desc: data.tax_desc,
    start_dt: data.start_dt,
    end_dt: data.end_dt,
    tax_pct: data.tax_pct,
    tax_amt: data.tax_amt,
    display_seq: data.display_seq,
    is_in_use: data.is_in_use,
  };

  $.ajax({
    url: "http://localhost:3500/admin/tax/save",
    method: "POST",
    dataType: "json",
    data: requestData,
    success: function (response) {
      console.log(response);

      if (self.currItem.data.tax_id === undefined) {
        // Create new record
        const newUomId = response.data.tax_id; // Replace with the actual response key

        const newData = {
          tax_id: newUomId,
          tax_code: data.tax_code,
          tax_desc: data.tax_desc,
          start_dt: data.start_dt,
          end_dt: data.end_dt,
          tax_pct: data.tax_pct,
          tax_amt: data.tax_amt,
          display_seq: data.display_seq,
          is_in_use: data.is_in_use,
        };

        const c2 = ct
          .clone()
          .removeClass("tax-item0")
          .addClass("item-content")
          .data("data", newData);

        c2.find(".tax-code").text(newData.tax_code);
        c2.find(".modified-on").text(formatDateTime(response.data.modified_on));
        c2.find(".modified-by").text(response.data.modified_by);

        self.currItem = { item: c2, data: newData }; // Use the saved 'self' context
        console.log(self.currItem);
        taxList.prepend(c2);
      } else {
        // Update existing record
        self.currItem.data.tax_code = data.tax_code;
        self.currItem.data.tax_desc = data.tax_desc;
        self.currItem.data.start_dt = data.start_dt;
        self.currItem.data.end_dt = data.end_dt;
        self.currItem.data.tax_pct = data.tax_pct;
        self.currItem.data.tax_amt = data.tax_amt;
        self.currItem.data.display_seq = data.display_seq;
        self.currItem.data.modified_on = response.data.modified_on;
        self.currItem.data.modified_by = response.data.modified_by;

        self.currItem.item.find(".tax_code").text(self.currItem.data.tax_code);
        self.currItem.item
          .find(".display-seq-input")
          .text(self.currItem.data.display_seq);
        self.currItem.item
          .find(".modified-on")
          .text(formatDate(self.currItem.data.modified_on));
        self.currItem.item
          .find(".modified-by")
          .text(self.currItem.data.modified_by);
        self.currItem.item.data("data", self.currItem.data);
      }

      // Show Popup
      if (response.data.result === "OK") {
        var successMsg = "The record has been saved.";
        $("#popup-message").text(successMsg);
        $("#popup-container").show();
      } else {
        $("#popup-message").text(response.data.result);
        $("#popup-container").show();
      }
      $("#popup-close-btn").on("click", function () {
        $("#popup-container").hide();
      });
    },
    error: function (xhr, status, error) {
      // Handle error if the AJAX request fails
      console.error(error);
    },
  });
};

// $(document).on("click", ".btn-save", function (e) {
//   e.preventDefault();

//   // Retrieve the input values
//   // var addonId =
//   var taxId = $(".tax-id-input").val();
//   var taxCode = $(".code-input").val();
//   var taxDescription = $(".desc-input").val();
//   var startDt = $(".start-dt-input").val();
//   var endDt = $(".end-dt-input").val();
//   var taxPct = parseFloat($(".tax-pct-input").val());
//   var taxAmt =
//     parseFloat($(".tax-amt-input").val()).toFixed(2) !== ""
//       ? parseFloat($(".tax-amt-input").val()).toFixed(2)
//       : null;
//   var displaySequence = $(".display-seq-input").val();
//   var isActive = $(".is-active-input").hasClass("btn-checkbox") ? "1" : "0";
//   console.log(taxId);
//   console.log(taxDescription);
//   console.log(taxPct);
//   console.log(typeof taxPct);

//   // Create an object with the addon data
//   var taxData = {
//     taxId: taxId !== "" ? taxId : undefined,
//     taxCode: taxCode,
//     taxDescription: taxDescription,
//     startDt: startDt,
//     endDt: endDt,
//     taxPct: taxPct,
//     taxAmt: taxAmt,
//     displaySequence: displaySequence,
//     isActive: isActive,
//   };

//   console.log(taxData);

//   // Perform an AJAX request to create the addon
//   $.ajax({
//     url: "http://localhost:3500/tax/save", // Update the URL according to your backend endpoint for creating an addon
//     method: "POST",
//     dataType: "json",
//     data: {
//       current_uid: "admin",
//       tax_id: taxData.taxId,
//       tax_code: taxData.taxCode,
//       tax_desc: taxData.taxDescription,
//       start_dt: taxData.startDt,
//       end_dt: taxData.endDt,
//       tax_pct: taxData.taxPct,
//       tax_amt: taxData.taxAmt,
//       display_seq: taxData.displaySequence,
//       is_in_use: taxData.isActive,
//     },
//     success: function (response) {
//       // Handle the successful response from the backend
//       console.log(response);
//       // Clear the input fields
//       $(".tax-id-input").val("");
//       $(".code-input").val("");
//       $(".tax-desc-input").val("");
//       $(".start-dt-input").val("");
//       $(".end-dt-input").val("");
//       $(".tax-pct-input").val("");
//       $(".tax-amt-input").val("");
//       $(".display-seq-input").val("");
//       $(".is-active-input").removeClass("is-active");
//       console.log(response.output.result);
//       // Show Popup
//       if (response.output.result === "OK") {
//         var successMsg = "The record have been saved.";
//         $("#popup-message").text(successMsg);
//         $("#popup-container").show();
//       } else {
//         $("#popup-message").text(response.output.result);
//         $("#popup-container").show();
//       }
//       $("#popup-close-btn").on("click", function () {
//         $("#popup-container").hide();
//       });
//     },
//     error: function (xhr, status, error) {
//       // Handle any errors that occurred during the request
//       console.error(error);
//     },
//   });
// });

// Delete
// $(document).on("click", ".btn-delete", function (e) {
//   e.preventDefault();

//   // Retrieve the addon ID from the clicked element or any other source
//   var taxId = $(".tax-id-input").val();
//   console.log(taxId);
//   // Perform an AJAX request to delete the addon
//   $.ajax({
//     url: "http://localhost:3500/tax/delete", // Update the URL according to your backend endpoint for deleting an addon
//     method: "POST",
//     dataType: "json",
//     data: {
//       current_uid: "admin",
//       tax_id: taxId,
//     },
//     success: function (response) {
//       // Handle the successful response from the backend
//       console.log(response);
//       console.log(response.output.result);
//       // Perform any additional actions after deleting the addon
//       if (response.output.result === "OK") {
//         var successMsg = "The record have been deleted.";
//         $("#popup-message").text(successMsg);
//         $("#popup-container").show();
//       } else {
//         $("#popup-message").text(response.output.result);
//         $("#popup-container").show();
//       }
//       $("#popup-close-btn").on("click", function () {
//         $("#popup-container").hide();
//       });
//     },
//     error: function (xhr, status, error) {
//       // Handle any errors that occurred during the request
//       console.error(error);
//     },
//   });
// });

SetTax.prototype.handleTaxItemRemove = function (e) {
  const item = $(e.currentTarget).closest(".item-content");
  console.log(item);
  const taxId = item.data("data").tax_id;
  console.log(taxId);

  const self = this;
  $.ajax({
    url: "http://localhost:3500/admin/tax/delete", // Update the URL according to your backend endpoint for deleting an addon
    method: "POST",
    dataType: "json",
    data: {
      current_uid: sessionStorage.getItem("a"),
      tax_id: taxId,
    },
    success: function (response) {
      console.log(response);
      // Show Popup
      if (response.data.result === "OK") {
        var successMsg = "The record has been deleted.";
        $("#popup-message").text(successMsg);
        $("#popup-container").show();
      } else {
        $("#popup-message").text(response.data.result);
        $("#popup-container").show();
      }
      $("#popup-close-btn").on("click", function () {
        $("#popup-container").hide();
      });

      self.resetInputFields(); // Use the saved 'self' context

      if (response.data.result === "OK") {
        item.fadeOut(100, () => {
          item.remove();
        });
      }
    },
    error: function (xhr, status, error) {
      // Handle any errors that occurred during the request
      console.error(error);
    },
  });
};

//--------------------------------------//
//        Page Startup Function         //
//--------------------------------------//
$(() => {
  const setTax = new SetTax();
  setTax.init();
});
