"use strict";

function SetPaymentType() {
  this.currItem = { item: null, data: {} };
  this.pymtId = undefined;
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

function formatDateTime(dateFormat) {
  var date = new Date(dateFormat);

  var day = date.getDate().toString().padStart(2, "0");
  var month = (date.getMonth() + 1).toString().padStart(2, "0");
  var year = date.getFullYear();

  var hours = date.getHours().toString().padStart(2, "0");
  var minutes = date.getMinutes().toString().padStart(2, "0");
  var seconds = date.getSeconds().toString().padStart(2, "0");

  var fullDate = year + "-" + month + "-" + day;
  var fullTime = hours + ":" + minutes + ":" + seconds;

  return fullDate + " " + fullTime;
}

SetPaymentType.prototype.init = function () {
  const self = this;
  $.ajax({
    url: "http://localhost:3500/admin/payment/list",
    method: "POST",
    dataType: "json",
    data: {
      axn: "setup",
    },
    success: function (response) {
      console.log(response);
      const data = response.recordsets;
      console.log(data);
      const pymtItem = $(".item-list");
      pymtItem.empty();
      const clonePymtItem = $(".pymt-item0");

      data.forEach(function (itemArray) {
        itemArray.forEach(function (item) {
          const c2 = clonePymtItem
            .clone()
            .removeClass("pymt-item0")
            .addClass("item-content")
            .data("data", item);
          console.table(item);

          c2.find(".pymt-desc").text(item.pymt_type_desc);
          c2.find(".modified-on").text(formatDateTime(item.modified_on));
          c2.find(".modified-by").text(item.modified_by);

          pymtItem.append(c2);
        });

        pymtItem.on(
          "click",
          ".item-content",
          self.handlePymtItemClick.bind(self)
        );
        pymtItem.on(
          "click",
          ".btn-delete",
          self.handlePymtItemRemove.bind(self)
        );
      });
    },
    error: function () {
      console.log("An error has occurred.");
    },
  });

  $(".search-description").on("keyup", function () {
    self.handlePymtItemFilter();
  });

  $(".btn-add").on("click", function () {
    self.resetInputFields();
  });

  $(".btn-save").on("click", function () {
    self.handlePymtItemSave();
  });

  $(".btn-select, .sys-pymt-type-input").on("click", function () {
    self.handleSysPymtItem();
  });
};

SetPaymentType.prototype.handlePymtItemSave = function () {
  const idInput = $(".pymt-id-input");
  const descInput = $(".pymt-desc-input");
  const allowChangeDue = $(".allow-chg-due-input").hasClass("btn-checkbox")
    ? "1"
    : "0";
  const getCard = $(".get-card-input").hasClass("btn-checkbox") ? "1" : "0";
  const getRef = $(".get-ref-input").hasClass("btn-checkbox") ? "1" : "0";
  const displaySeqInput = $(".display-seq-input");
  const isActive = $(".is-active-input").hasClass("btn-checkbox") ? "1" : "0";

  const ct = $(".pymt-item0");
  const pymtList = $(".item-list");
  const self = this;

  const data = {
    current_uid: sessionStorage.getItem("a"),
    pymt_type_id: idInput.val() !== "" ? idInput.val() : undefined,
    pymt_type_desc: descInput.val(),
    allow_payment_change_due: allowChangeDue,
    get_credit_card_detail: getCard,
    get_ref_no: getRef,
    display_seq: displaySeqInput.val(),
    is_in_use: isActive,
  };

  console.log(data.pymt_type_id);

  const requestData = {
    current_uid: data.current_uid,
    pymt_type_id: data.pymt_type_id,
    pymt_type_desc: data.pymt_type_desc,
    allow_payment_change_due: data.allow_payment_change_due,
    get_credit_card_detail: data.get_credit_card_detail,
    get_ref_no: data.get_ref_no,
    display_seq: data.display_seq,
    is_in_use: data.is_in_use,
  };

  $.ajax({
    url: "http://localhost:3500/admin/payment/save",
    method: "POST",
    dataType: "json",
    data: requestData,
    success: function (response) {
      console.log(response);

      if (self.currItem.data.pymt_type_id === undefined) {
        // Create new record
        const newPymtId = response.data.pymt_type_id; // Replace with the actual response key

        const newData = {
          pymt_type_id: newPymtId,
          pymt_type_desc: data.pymt_type_desc,
          allow_payment_change_due: data.allow_payment_change_due,
          get_credit_card_detail: data.get_credit_card_detail,
          get_ref_no: data.get_ref_no,
          display_seq: data.display_seq,
          is_in_use: data.is_in_use,
        };

        const c2 = ct
          .clone()
          .removeClass("pymt-item0")
          .addClass("item-content")
          .data("data", newData);

        c2.find(".pymt-desc").text(newData.pymt_type_desc);
        c2.find(".modified-on").text(formatDateTime(response.data.modified_on));
        c2.find(".modified-by").text(response.data.modified_by);

        self.currItem = { item: c2, data: newData }; // Use the saved 'self' context
        console.log(self.currItem);
        pymtList.prepend(c2);
      } else {
        // Update existing record
        self.currItem.data.pymt_type_desc = data.pymt_type_desc;
        self.currItem.data.allow_payment_change_due =
          data.allow_payment_change_due;
        self.currItem.data.get_credit_card_detail = data.get_credit_card_detail;
        self.currItem.data.get_ref_no = data.get_ref_no;
        self.currItem.data.display_seq = data.display_seq;
        self.currItem.data.modified_on = response.data.modified_on;
        self.currItem.data.modified_by = response.data.modified_by;

        self.currItem.item
          .find(".pymt-desc")
          .text(self.currItem.data.pymt_type_desc);
        self.currItem.item
          .find(".allow-chg-due-input")
          .text(self.currItem.data.allow_payment_change_due);
        self.currItem.item
          .find(".get-card-input")
          .text(self.currItem.data.get_credit_card_detail);
        self.currItem.item
          .find(".get-ref-input")
          .text(self.currItem.data.get_ref_no);
        self.currItem.item
          .find(".display-seq-input")
          .text(self.currItem.data.display_seq);
        self.currItem.item
          .find(".modified-on")
          .text(formatDateTime(self.currItem.data.modified_on));
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
//   var paymentId = $(".pymt-id-input").val();
//   var paymentDescription = $(".pymt-desc-input").val();
//   var sysPymtType = $(".sys-pymt-type-id").val();
//   var displaySequence = $(".display-seq-input").val();
//   var isActive = $(".is-active-input").hasClass("btn-checkbox") ? "1" : "0";
//   var allowChangeDue = $(".allow-chg-due-input").hasClass("btn-checkbox")
//     ? 1
//     : "0";
//   var getCc = $(".get-card-input").hasClass("btn-checkbox") ? "1" : "0";
//   var getRefNo = $(".get-ref-input").hasClass("btn-checkbox") ? "1" : "0";
//   // Create an object with the addon data
//   var paymentData = {
//     paymentId: paymentId !== "" ? paymentId : undefined,
//     paymentDescription: paymentDescription,
//     sysPymtType: sysPymtType,
//     isActive: isActive,
//     displaySequence: displaySequence,
//     allowChangeDue: allowChangeDue,
//     getCc: getCc,
//     getRefNo: getRefNo,
//   };

//   // Perform an AJAX request to create the addon
//   $.ajax({
//     url: "http://localhost:3500/payment/save", // Update the URL according to your backend endpoint for creating an addon
//     method: "POST",
//     dataType: "json",
//     data: {
//       current_uid: "admin",
//       pymt_type_id: paymentData.paymentId,
//       pymt_type_desc: paymentData.paymentDescription,
//       sys_pymt_type_id: paymentData.sysPymtType,
//       is_in_use: paymentData.isActive,
//       display_seq: paymentData.displaySequence,
//       allow_payment_change_due: allowChangeDue,
//       get_credit_card_detail: getCc,
//       get_ref_no: getRefNo,
//     },
//     success: function (response) {
//       // Handle the successful response from the backend
//       console.log(response);
//       // Clear the input fields
//       $(".pymt-id-input").val("");
//       $(".pymt-desc-input").val("");
//       $(".sys-pymt-type-input").val("");
//       $(".display-seq-input").val("");
//       $(".is-active-input").removeClass("is-active");
//       $(".allow-chg-due-input").removeClass("is-active");
//       $(".get-card-input").removeClass("is-active");
//       $(".get-ref-input").removeClass("is-active");
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

SetPaymentType.prototype.handleSysPymtItem = function () {
  $.ajax({
    url: "http://localhost:3500/admin/payment/sys_pymt_type",
    method: "POST",
    dataType: "json",
    data: {},
    success: function (response) {
      console.log(response);

      // Show the popup
      $("#sys-pymt-type").show();

      // Retrieve and populate the items
      var items = response.recordsets[0]; // Replace with the actual response data structure
      console.log(items);
      var itemContainer = $("#sys-pymt-type-item");
      itemContainer.empty();
      const cloneSysItem = $(".item0");
      // Add items to the container
      items.forEach(function (item) {
        const c2 = cloneSysItem
          .clone()
          .removeClass("item0")
          .addClass("item")
          .data("data", item);
        console.table(item);

        c2.find(".sys-pymt-type-desc").text(item.sys_pymt_type_desc);

        itemContainer.append(c2);
      });
      itemContainer.on("click", ".item", function (e) {
        SetPaymentType.prototype.handleSysPymtItemClick.call(this, e);
      });
    },
    error: function (xhr, status, error) {
      // Handle any errors that occurred during the request
      console.error(error);
    },
  });

  $("#sys-pymt-type-close-btn").on("click", function () {
    $("#sys-pymt-type").hide();
  });
};

SetPaymentType.prototype.handleSysPymtItemClick = function (e) {
  console.log(11);
  const item = $(e.currentTarget).closest(".item");
  const data = item.data("data");
  console.log(data);

  $(".sys-pymt-type-input").val(data.sys_pymt_type_desc);
  $(".sys-pymt-type-id").val(data.sys_pymt_type_id);
};

SetPaymentType.prototype.handlePymtItemClick = function (e) {
  console.log(11);
  const item = $(e.currentTarget).closest(".item-content");
  const data = item.data("data");
  console.log(data);
  this.currItem = { item, data };

  $(".pymt-id-input").val(data.pymt_type_id);
  $(".pymt-desc-input").val(data.pymt_type_desc);
  $(".sys-pymt-type-input").val(data.sys_pymt_type_desc);
  $(".sys-pymt-type-id").val(data.sys_pymt_type_id);
  $(".display-seq-input").val(data.display_seq);
  var isCheckboxACDActive = data.allow_payment_change_due === 1;
  $(".allow-change-due-input")
    .toggleClass("btn-checkbox", isCheckboxACDActive)
    .toggleClass("btn-checkbox0", !isCheckboxACDActive);
  var isCheckboxCActive = data.get_credit_card_detail === 1;
  $(".get-card-input")
    .toggleClass("btn-checkbox", isCheckboxCActive)
    .toggleClass("btn-checkbox0", !isCheckboxCActive);
  var isCheckboxRActive = data.get_ref_no === 1;
  $(".get-ref-input")
    .toggleClass("btn-checkbox", isCheckboxRActive)
    .toggleClass("btn-checkbox0", !isCheckboxRActive);
  var isCheckboxActive = data.is_in_use === 1;
  $(".is-active-input")
    .toggleClass("btn-checkbox", isCheckboxActive)
    .toggleClass("btn-checkbox0", !isCheckboxActive);
};

SetPaymentType.prototype.resetInputFields = function () {
  $(
    ".pymt-id-input, .pymt-desc-input, .sys-pymt-type-id-input, .sys-pymt-type-input, .display-seq-input"
  ).val("");
  $(".allow-change-due-input").removeClass("btn-checkbox");
  $(".allow-change-due-input").addClass("btn-checkbox0");
  $(".get-card-input").removeClass("btn-checkbox");
  $(".get-card-input").addClass("btn-checkbox0");
  $(".get-ref-input").removeClass("btn-checkbox");
  $(".get-ref-input").addClass("btn-checkbox0");
  $(".is-active-input").removeClass("btn-checkbox");
  $(".is-active-input").addClass("btn-checkbox0");
  this.currItem = { item: null, data: {} };
};

SetPaymentType.prototype.handlePymtItemRemove = function (e) {
  const item = $(e.currentTarget).closest(".item-content");
  console.log(item);
  const pymtId = item.data("data").pymt_type_id;
  console.log(pymtId);

  const self = this;
  $.ajax({
    url: "http://localhost:3500/admin/payment/delete", // Update the URL according to your backend endpoint for deleting an addon
    method: "POST",
    dataType: "json",
    data: {
      current_uid: sessionStorage.getItem("a"),
      pymt_type_id: pymtId,
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
  const setPymt = new SetPaymentType();
  setPymt.init();
});
