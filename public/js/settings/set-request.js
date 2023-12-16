"use strict";

function SetRequest() {
  this.currItem = { item: null, data: {} };
  this.requestId = undefined;
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

SetRequest.prototype.handleRequestItemFilter = function () {
  const fields = $(".search-description").val().toUpperCase();

  $(".item-content").each(function () {
    const name = $(this).find(".request-code").text().toUpperCase();
    $(this).toggle(name.includes(fields));
  });
};

SetRequest.prototype.init = function () {
  const self = this;
  $.ajax({
    url: "http://localhost:3500/admin/request/list",
    method: "POST",
    dataType: "json",
    data: {
      axn: "setup",
    },
    success: function (response) {
      console.log(response);
      const data = response.recordsets;
      console.log(data);
      const requestItem = $(".item-list");
      requestItem.empty();
      const cloneRequestItem = $(".request-item0");

      data.forEach(function (itemArray) {
        itemArray.forEach(function (item) {
          const c2 = cloneRequestItem
            .clone()
            .removeClass("request-item0")
            .addClass("item-content")
            .data("data", item);
          console.table(item);

          c2.find(".request-code").text(item.request_code);
          c2.find(".modified-on").text(formatDateTime(item.modified_on));
          c2.find(".modified-by").text(item.modified_by);

          requestItem.append(c2);
        });

        requestItem.on(
          "click",
          ".item-content",
          self.handleRequestItemClick.bind(self)
        );
        requestItem.on(
          "click",
          ".btn-delete",
          self.handleRequestItemRemove.bind(self)
        );
      });
    },
    error: function () {
      console.log("An error has occurred.");
    },
  });

  $(".search-description").on("keyup", function () {
    self.handleRequestItemFilter();
  });

  $(".btn-add").on("click", function () {
    self.resetInputFields();
  });

  $(".btn-save").on("click", function () {
    self.handleRequestItemSave();
  });
};

SetRequest.prototype.handleRequestItemClick = function (e) {
  console.log(11);
  const item = $(e.currentTarget).closest(".item-content");
  const data = item.data("data");
  console.log(data);
  this.currItem = { item, data };

  $(".request-id-input").val(data.request_id);
  $(".request-code-input").val(data.request_code);
  $(".request-desc-input").val(data.request_desc);
  $(".group-code-input").val(data.group_code);
  $(".remarks-input").val(data.remarks);
  $(".display-seq-input").val(data.display_seq);
  var isCheckboxActive = data.is_in_use === 1;
  $(".is-active-input")
    .toggleClass("btn-checkbox", isCheckboxActive)
    .toggleClass("btn-checkbox0", !isCheckboxActive);
};
// $(document).on("click", ".request-item", function () {
//   var c0 = $(this).data("data");
//   console.log(c0);
//   // Get the clicked addon's content
//   var requestId = c0.request_id;
//   var isActive = c0.is_in_use;
//   // Set the content in the HTML input tags
//   $(".request-id-input").val(requestId);
//   $(".request-code-input").val(c0.request_code);
//   $(".request-desc-input").val(c0.request_desc);
//   $(".group-code-input").val(c0.group_code);
//   $(".remarks-input").val(c0.remarks);
//   $(".display-seq-input").val(c0.display_seq);
//   var isCheckboxActive = isActive === 1;
//   $(".is-active-input").toggleClass("btn-checkbox", isCheckboxActive);
//   $(".is-active-input").toggleClass("btn-checkbox0", !isCheckboxActive);
// });

// $(document).on("click", ".btn-add", function (e) {
//   e.preventDefault();

//   // Retrieve the input values
//   $(".request-id-input").val("");
//   $(".request-code-input").val("");
//   $(".request-desc-input").val("");
//   $(".group-code-input").val("");
//   $(".remarks-input").val("");
//   $(".display-seq-input").val("");
//   $(".is-active-input").removeClass("btn-checkbox");
//   $(".is-active-input").addClass("btn-checkbox0");
// });

SetRequest.prototype.resetInputFields = function () {
  $(
    ".request-id-input, .request-code-input, .request-desc-input, .remarks-input, .group-code-input, .display-seq-input"
  ).val("");
  $(".is-active-input").removeClass("btn-checkbox");
  $(".is-active-input").addClass("btn-checkbox0");
  this.currItem = { item: null, data: {} };
};

// $(document).on("click", ".btn-save", function (e) {
//   e.preventDefault();

//   // Retrieve the input values
//   // var addonId =
//   var requestId = $(".request-id-input").val();
//   var requestCode = $(".request-code-input").val();
//   var requestDescription = $(".request-desc-input").val();
//   var group = $(".group-code-input").val();
//   var remarks = $(".remarks-input").val();
//   var displaySequence = $(".display-seq-input").val();
//   var isActive = $(".is-active-input").hasClass("btn-checkbox") ? "1" : "0";
//   console.log(requestId);
//   console.log(requestDescription);

//   // Create an object with the addon data
//   var requestData = {
//     requestId: requestId !== "" ? requestId : undefined,
//     requestCode: requestCode,
//     requestDescription: requestDescription,
//     group: group,
//     remarks: remarks,
//     displaySequence: displaySequence,
//     isActive: isActive,
//   };

//   console.log(requestData);

//   // Perform an AJAX request to create the addon
//   $.ajax({
//     url: "http://localhost:3500/request/save", // Update the URL according to your backend endpoint for creating an addon
//     method: "POST",
//     dataType: "json",
//     data: {
//       current_uid: "admin",
//       request_id: requestData.requestId,
//       request_code: requestData.requestCode,
//       request_desc: requestData.requestDescription,
//       group_code: requestData.group,
//       remarks: requestData.remarks,
//       display_seq: requestData.displaySequence,
//       is_in_use: requestData.isActive,
//     },
//     success: function (response) {
//       // Handle the successful response from the backend
//       console.log(response);
//       // Clear the input fields
//       $(".prod-cat-id-input").val("");
//       $(".prod-cat-desc-input").val("");
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

SetRequest.prototype.handleRequestItemSave = function () {
  const idInput = $(".request-id-input");
  const codeInput = $(".request-code-input");
  const descInput = $(".request-desc-input");
  const groupInput = $(".group-code-input");
  const remarkInput = $(".remarks-input");
  const displaySeqInput = $(".display-seq-input");
  const isActive = $(".is-active-input").hasClass("btn-checkbox") ? "1" : "0";

  const ct = $(".request-item0");
  const requestList = $(".item-list");
  const self = this;

  const data = {
    current_uid: sessionStorage.getItem("a"),
    request_id: idInput.val() !== "" ? idInput.val() : undefined,
    request_code: codeInput.val(),
    request_desc: descInput.val(),
    group_code: groupInput.val(),
    remarks: remarkInput.val(),
    display_seq: displaySeqInput.val(),
    is_in_use: isActive,
  };

  console.log(data.request_id);

  const requestData = {
    current_uid: data.current_uid,
    request_id: data.request_id,
    request_code: data.request_code,
    request_desc: data.request_desc,
    group_code: data.group_code,
    remarks: data.remarks,
    display_seq: data.display_seq,
    is_in_use: data.is_in_use,
  };

  $.ajax({
    url: "http://localhost:3500/admin/request/save",
    method: "POST",
    dataType: "json",
    data: requestData,
    success: function (response) {
      console.log(response);

      if (self.currItem.data.request_id === undefined) {
        // Create new record
        const newRequestId = response.data.request_id; // Replace with the actual response key

        const newData = {
          request_id: newRequestId,
          request_code: data.request_code,
          request_desc: data.request_desc,
          group_code: data.group_code,
          remarks: data.remarks,
          display_seq: data.display_seq,
          is_in_use: data.is_in_use,
        };

        const c2 = ct
          .clone()
          .removeClass("request-item0")
          .addClass("item-content")
          .data("data", newData);

        c2.find(".request-code").text(newData.request_code);
        c2.find(".request-desc").text(newData.request_desc);
        c2.find(".group-code-input").text(newData.group_code);
        c2.find(".remarks-input").text(newData.remarks);
        c2.find(".modified-on").text(formatDateTime(response.data.modified_on));
        c2.find(".modified-by").text(response.data.modified_by);

        self.currItem = { item: c2, data: newData }; // Use the saved 'self' context
        console.log(self.currItem);
        requestList.prepend(c2);
      } else {
        // Update existing record
        self.currItem.data.request_code = data.request_code;
        self.currItem.data.request_desc = data.request_desc;
        self.currItem.data.group_code = data.group_code;
        self.currItem.data.remarks = data.remarks;
        self.currItem.data.display_seq = data.display_seq;
        self.currItem.data.modified_on = response.data.modified_on;
        self.currItem.data.modified_by = response.data.modified_by;

        self.currItem.item
          .find(".request-code")
          .text(self.currItem.data.request_code);
        self.currItem.item
          .find(".request-desc")
          .text(self.currItem.data.request_desc);
        self.currItem.item
          .find(".group-code-input")
          .text(self.currItem.data.group_code);
        self.currItem.item
          .find(".remarks-input")
          .text(self.currItem.data.remarks);
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

SetRequest.prototype.handleRequestItemRemove = function (e) {
  const item = $(e.currentTarget).closest(".item-content");
  console.log(item);
  const requestId = item.data("data").request_id;
  console.log(requestId);

  const self = this;

  $.ajax({
    url: "http://localhost:3500/admin/request/delete", // Update the URL according to your backend endpoint for deleting an addon
    method: "POST",
    dataType: "json",
    data: {
      current_uid: sessionStorage.getItem("a"),
      request_id: requestId,
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

// $(document).on("click", ".btn-delete", function (e) {
//   e.preventDefault();

//   // Retrieve the addon ID from the clicked element or any other source
//   var requestId = $(".request-id-input").val();
//   console.log(requestId);
//   // Perform an AJAX request to delete the addon
//   $.ajax({
//     url: "http://localhost:3500/request/delete", // Update the URL according to your backend endpoint for deleting an addon
//     method: "POST",
//     dataType: "json",
//     data: { current_uid: "admin", request_id: requestId },
//     success: function (response) {
//       // Handle the successful response from the backend
//       console.log(response);
//       // Perform any additional actions after deleting the addon
//       if (response.output.result === "OK") {
//         var successMsg = "The record have been deleted!";
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

//--------------------------------------//
//        Page Startup Function         //
//--------------------------------------//
$(() => {
  const setRequest = new SetRequest();
  setRequest.init();
});
