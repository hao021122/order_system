"use strict";

function SetUom() {
  this.currItem = { item: null, data: {} };
  this.uomId = undefined;
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

SetUom.prototype.handleUomItemFilter = function () {
  const fields = $(".search-description").val().toUpperCase();

  $(".item-content").each(function () {
    const name = $(this).find(".uom-desc").text().toUpperCase();
    $(this).toggle(name.includes(fields));
  });
};

SetUom.prototype.init = function () {
  const self = this;
  $.ajax({
    url: "http://localhost:3500/admin/uom/list",
    method: "POST",
    dataType: "json",
    data: {
      axn: "setup",
    },
    success: function (response) {
      console.log(response);
      const data = response.recordsets;
      console.log(data);
      const uomItem = $(".item-list");
      uomItem.empty();
      const cloneUomItem = $(".uom-item0");

      data.forEach(function (itemArray) {
        itemArray.forEach(function (item) {
          const c2 = cloneUomItem
            .clone()
            .removeClass("uom-item0")
            .addClass("item-content")
            .data("data", item);
          console.table(item);

          c2.find(".uom-desc").text(item.uom_desc);
          c2.find(".modified-on").text(formatDateTime(item.modified_on));
          c2.find(".modified-by").text(item.modified_by);

          uomItem.append(c2);
        });

        uomItem.on(
          "click",
          ".item-content",
          self.handleUomItemClick.bind(self)
        );
        uomItem.on("click", ".btn-delete", self.handleUomItemRemove.bind(self));
      });
    },
    error: function () {
      console.log("An error has occurred.");
    },
  });

  $(".search-description").on("keyup", function () {
    self.handleUomItemFilter();
  });

  $(".btn-add").on("click", function () {
    self.resetInputFields();
  });

  $(".btn-save").on("click", function () {
    self.handleUomItemSave();
  });
};

// $.ajax({
//   url: "http://localhost:3500/uom", // Update the URL according to your backend endpoint
//   method: "POST",
//   dataType: "json",
//   data: {
//     axn: "setup",
//   },
//   success: function (response) {
//     // Handle the successful response from the backend
//     console.log(response);
//     console.log(response.recordset);

//     // Update the UI with the retrieved data
//     var itemList = $(".item-list");
//     var content = response.recordsets;
//     var data = JSON.stringify(content);
//     console.log(data);

//     // Iterate over the retrieved addons and generate HTML for each addon
//     content.forEach(function (uomArray) {
//       uomArray.forEach(function (uom) {
//         var uomItem = $('<div class="uom-item"></div>');

//         // Store the addon ID as a data attribute on the addon item
//         uomItem.data("data", uom);
//         console.log(uom);
//         // Create and append the UI elements for the desired data fields
//         // $(
//         //   '<div class="uom-id" style="display:none;">' + uom.uom_id + "</div>"
//         // ).appendTo(uomItem);
//         $('<div class="uom-desc">' + uom.uom_desc + "</div>").appendTo(uomItem);
//         // $(
//         //   '<div class="uom-display-seq" style="display:none;">' +
//         //     uom.display_seq +
//         //     "</div>"
//         // ).appendTo(uomItem);
//         $(
//           '<div class="modified-on">' +
//             formatDateTime(uom.modified_on) +
//             "</div>"
//         ).appendTo(uomItem);
//         $('<div class="modified-by">' + uom.modified_by + "</div>").appendTo(
//           uomItem
//         );

//         // Add more UI elements as needed

//         // Append the addon item to the item list
//         itemList.append(uomItem);
//         console.log(uomItem);
//       });
//     });
//   },
//   error: function (xhr, status, error) {
//     // Handle any errors that occurred during the request
//     console.error(error);
//   },
// });

SetUom.prototype.handleUomItemClick = function (e) {
  console.log(11);
  const item = $(e.currentTarget).closest(".item-content");
  const data = item.data("data");
  console.log(data);
  this.currItem = { item, data };

  $(".uom-id-input").val(data.uom_id);
  $(".uom-desc-input").val(data.uom_desc);
  $(".display-seq-input").val(data.display_seq);
  var isCheckboxActive = data.is_in_use === 1;
  $(".is-active-input")
    .toggleClass("btn-checkbox", isCheckboxActive)
    .toggleClass("btn-checkbox0", !isCheckboxActive);
};

// $(document).on("click", ".btn-add", function (e) {
//   e.preventDefault();

//   // Retrieve the input values
//   $(".uom-id-input").val("");
//   $(".uom-desc-input").val("");
//   $(".display-seq-input").val("");
//   $(".is-active-input").removeClass("btn-checkbox");
//   $(".is-active-input").addClass("btn-checkbox0");
// });

// $(document).on("click", ".btn-save", function (e) {
//   e.preventDefault();

//   // Retrieve the input values
//   // var addonId =
//   var uomId = $(".uom-id-input").val();
//   var uomDescription = $(".uom-desc-input").val();
//   var displaySequence = $(".display-seq-input").val();
//   var isActive = $(".is-active-input").hasClass("btn-checkbox") ? "1" : "0";

//   // Create an object with the addon data
//   var uomData = {
//     uomId: uomId !== "" ? uomId : undefined,
//     uomDescription: uomDescription,
//     displaySequence: displaySequence,
//     isActive: isActive,
//   };

//   console.log(uomData);

//   // Perform an AJAX request to create the addon
//   $.ajax({
//     url: "http://localhost:3500/uom/save", // Update the URL according to your backend endpoint for creating an addon
//     method: "POST",
//     dataType: "json",
//     data: {
//       current_uid: "admin",
//       uom_id: uomData.uomId,
//       uom_desc: uomData.uomDescription,
//       display_seq: uomData.displaySequence,
//       is_in_use: uomData.isActive,
//     },
//     success: function (response) {
//       // Handle the successful response from the backend
//       console.log(response);
//       // Clear the input fields
//       $(".uom-id-input").val("");
//       $(".uom-desc-input").val("");
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

SetUom.prototype.handleUomItemSave = function () {
  const idInput = $(".uom-id-input");
  const descInput = $(".uom-desc-input");
  const displaySeqInput = $(".display-seq-input");
  const isActive = $(".is-active-input").hasClass("btn-checkbox") ? "1" : "0";

  const ct = $(".uom-item0");
  const uomList = $(".item-list");
  const self = this;

  const data = {
    current_uid: sessionStorage.getItem("a"),
    uom_id: idInput.val() !== "" ? idInput.val() : undefined,
    uom_desc: descInput.val(),
    display_seq: displaySeqInput.val(),
    is_in_use: isActive,
  };

  console.log(data.uom_id);

  const requestData = {
    current_uid: data.current_uid,
    uom_id: data.uom_id,
    uom_desc: data.uom_desc,
    display_seq: data.display_seq,
    is_in_use: data.is_in_use,
  };

  $.ajax({
    url: "http://localhost:3500/admin/uom/save",
    method: "POST",
    dataType: "json",
    data: requestData,
    success: function (response) {
      console.log(response);

      if (self.currItem.data.uom_id === undefined) {
        // Create new record
        const newUomId = response.data.uom_id; // Replace with the actual response key

        const newData = {
          uom_id: newUomId,
          uom_desc: data.uom_desc,
          display_seq: data.display_seq,
          is_in_use: data.is_in_use,
        };

        const c2 = ct
          .clone()
          .removeClass("uom-item0")
          .addClass("item-content")
          .data("data", newData);

        c2.find(".uom-desc").text(newData.uom_desc);
        c2.find(".modified-on").text(formatDateTime(response.data.modified_on));
        c2.find(".modified-by").text(response.data.modified_by);

        self.currItem = { item: c2, data: newData }; // Use the saved 'self' context
        console.log(self.currItem);
        uomList.prepend(c2);
      } else {
        // Update existing record
        self.currItem.data.uom_desc = data.uom_desc;
        self.currItem.data.display_seq = data.display_seq;
        self.currItem.data.modified_on = response.data.modified_on;
        self.currItem.data.modified_by = response.data.modified_by;

        self.currItem.item.find(".uom-desc").text(self.currItem.data.uom_desc);
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

SetUom.prototype.resetInputFields = function () {
  $(".uom-id-input, .uom-desc-input, .display-seq-input").val("");
  $(".is-active-input").removeClass("btn-checkbox");
  $(".is-active-input").addClass("btn-checkbox0");
  this.currItem = { item: null, data: {} };
};

// Delete
SetUom.prototype.handleUomItemRemove = function (e) {
  const item = $(e.currentTarget).closest(".item-content");
  console.log(item);
  const uomId = item.data("data").uom_id;
  console.log(uomId);

  const self = this;
  $.ajax({
    url: "http://localhost:3500/admin/uom/delete", // Update the URL according to your backend endpoint for deleting an addon
    method: "POST",
    dataType: "json",
    data: {
      current_uid: sessionStorage.getItem("a"),
      uom_id: uomId,
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
//   var uomId = $(".uom-id-input").val();
//   console.log(uomId);
//   // Perform an AJAX request to delete the addon
//   $.ajax({
//     url: "http://localhost:3500/uom/delete", // Update the URL according to your backend endpoint for deleting an addon
//     method: "POST",
//     dataType: "json",
//     data: {
//       current_uid: "admin",
//       uom_id: uomId,
//     },
//     success: function (response) {
//       // Handle the successful response from the backend
//       console.log(response);
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

//--------------------------------------//
//        Page Startup Function         //
//--------------------------------------//
$(() => {
  const setUom = new SetUom();
  setUom.init();
});
