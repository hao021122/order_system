"use strict";

function SetAddon() {
  this.currItem = { item: null, data: {} };
  this.addonId = undefined;
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

// Perform AJAX request to retrieve the list of addons
// $.ajax({
//   url: "http://localhost:3500/addon", // Update the URL according to your backend endpoint
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

//     itemList.empty();

//     content.forEach(function (addonArray) {
//       // addonArray represents one recordset (an array of addons)
//       // You can iterate through this array to access individual addons
//       addonArray.forEach(function (addon) {
//         var addonItem = $('<div class="addon-item"></div>');

//         // Store the addon ID as a data attribute on the addon item
//         addonItem.data("data", addon);

//         // Create and append the UI elements for the desired data fields
//         $(
//           '<div class="items addon-code">' + addon.addon_code + "</div>"
//         ).appendTo(addonItem);
//         $(
//           '<div class="items addon-description">' + addon.addon_desc + "</div>"
//         ).appendTo(addonItem);
//         $(
//           '<div class="items modified-on">' +
//             formatDateTime(addon.modified_on) +
//             "</div>"
//         ).appendTo(addonItem);
//         $(
//           '<div class="items modified-by">' + addon.modified_by + "</div>"
//         ).appendTo(addonItem);

//         // Add more UI elements as needed

//         // Append the addon item to the item list
//         itemList.append(addonItem);
//       });
//     });
//   },
//   error: function (xhr, status, error) {
//     // Handle any errors that occurred during the request
//     console.error(error);
//   },
// });

// Filter the sreach
SetAddon.prototype.handleAddonItemFilter = function () {
  const fields = $(".search-description").val().toUpperCase();

  $(".item-content").each(function () {
    const name = $(this)
      .find(".addon-code, .addon-description")
      .text()
      .toUpperCase();
    $(this).toggle(name.includes(fields));
  });
};

SetAddon.prototype.init = function () {
  const self = this;
  $.ajax({
    url: "http://localhost:3500/admin/addon/list",
    method: "POST",
    dataType: "json",
    data: {
      axn: "setup",
    },
    success: function (response) {
      console.log(response);
      const data = response.recordsets;
      console.log(data);
      const addonItem = $(".item-list");
      addonItem.empty();
      const cloneAddonItem = $(".addon-item0");

      data.forEach(function (itemArray) {
        itemArray.forEach(function (item) {
          const c2 = cloneAddonItem
            .clone()
            .removeClass("addon-item0")
            .addClass("item-content")
            .data("data", item);
          console.table(item);

          c2.find(".addon-code").text(item.addon_code);
          c2.find(".addon-description").text(item.addon_desc);
          c2.find(".modified-on").text(formatDateTime(item.modified_on));
          c2.find(".modified-by").text(item.modified_by);

          addonItem.append(c2);
        });

        addonItem.on(
          "click",
          ".item-content",
          self.handleAddonItemClick.bind(self)
        );
        addonItem.on(
          "click",
          ".btn-delete",
          self.handleAddonItemRemove.bind(self)
        );
      });
    },
    error: function () {
      console.log("An error has occurred.");
    },
  });

  $(".search-description").on("keyup", function () {
    self.handleAddonItemFilter();
  });

  $(".btn-add").on("click", function () {
    self.resetInputFields();
  });

  $(".btn-save").on("click", function () {
    self.handleAddonItemSave();
  });
};

SetAddon.prototype.handleAddonItemClick = function (e) {
  // console.log(11);
  const item = $(e.currentTarget).closest(".item-content");
  const data = item.data("data");
  console.log(data);
  this.currItem = { item, data };

  $(".addon-id-input").val(data.addon_id);
  $(".addon-code-input").val(data.addon_code);
  $(".addon-desc-input").val(data.addon_desc);
  $(".remark-input").val(data.remark);
  $(".amt-input").val(data.amt);
  $(".display-seq-input").val(data.display_seq);
  var isCheckboxActive = data.is_in_use === 1;
  $(".is-active-input")
    .toggleClass("btn-checkbox", isCheckboxActive)
    .toggleClass("btn-checkbox0", !isCheckboxActive);
};

// SetAddon.prototype.handleAddonItemSave = function (e) {
//   const idInput = $(".addon-id-input");
//   const codeInput = $(".addon-code-input");
//   const descInput = $(".addon-desc-input");
//   const remarkInput = $(".remark-input");
//   const amtInput = $(".amt-input");
//   const displaySeqInput = $(".display-seq-input");
//   const isActive = $(".is-active-input").hasClass("btn-checkbox") ? "1" : "0";

//   const ct = $(".addon-item0");
//   const addonList = $(".item-list");
//   const self = this;

//   const data = {
//     current_uid: "admin",
//     addon_id: idInput.val(),
//     addon_code: codeInput.val(),
//     addon_desc: descInput.val(),
//     remark: remarkInput.val(),
//     amt: amtInput.val(),
//     display_seq: displaySeqInput.val(),
//     is_in_use: isActive,
//   };

//   const requestData = {
//     current_uid: data.current_uid,
//     addon_id: data.addon_id,
//     addon_code: data.addon_code,
//     addon_desc: data.addon_desc,
//     remark: data.remark,
//     amt: data.amt,
//     display_seq: data.display_seq,
//     is_in_use: data.is_in_use,
//   };

//   $.ajax({
//     url: "http://localhost:3500/addon/save",
//     method: "POST",
//     dataType: "json",
//     data: requestData,
//     success: function (response) {
//       console.log(response);

//       if (!self.currItem.data.addon_id) {
//         // Create new record
//         const newAddonId = response.data.addon_id; // Replace with the actual response key

//         const data = {
//           addon_id: newAddonId,
//           addon_code: addon_code,
//           addon_desc: addon_desc,
//           remark: remark,
//           amt: amt,
//           display_seq: display_seq,
//           is_in_use: isActive,
//         };

//         const c2 = ct
//           .clone()
//           .removeClass("addon-item0")
//           .addClass("item-content")
//           .data("data", data);

//         c2.find(".addon-code").text(data.addon_code);
//         c2.find(".addon-desc").text(data.addon_desc);

//         self.currItem = { item: c2, data: data }; // Use the saved 'self' context

//         addonList.prepend(c2);
//       } else {
//         // Update existing record
//         self.currItem.data.addon_code = codeInput.val();
//         self.currItem.data.addon_desc = descInput.val();

//         self.currItem.item
//           .find(".addon-code")
//           .text(self.currItem.data.addon_code);
//         self.currItem.item
//           .find(".addon-desc")
//           .text(self.currItem.data.addon_desc);
//         self.currItem.item.data("data", self.currItem.data);
//       }

//       // Show Popup
//       if (response.data.result === "OK") {
//         var successMsg = "The record has been saved.";
//         $("#popup-message").text(successMsg);
//         $("#popup-container").show();
//       } else {
//         $("#popup-message").text(response.data.result);
//         $("#popup-container").show();
//       }
//       $("#popup-close-btn").on("click", function () {
//         $("#popup-container").hide();
//       });
//     },
//     error: function (xhr, status, error) {
//       // Handle error if the AJAX request fails
//       console.error(error);
//     },
//   });
// };

SetAddon.prototype.handleAddonItemSave = function () {
  const idInput = $(".addon-id-input");
  const codeInput = $(".addon-code-input");
  const descInput = $(".addon-desc-input");
  const remarkInput = $(".remark-input");
  const amtInput = $(".amt-input");
  const displaySeqInput = $(".display-seq-input");
  const isActive = $(".is-active-input").hasClass("btn-checkbox") ? "1" : "0";

  if (!codeInput.val()) {
    
  }

  const ct = $(".addon-item0");
  const addonList = $(".item-list");
  const self = this;

  const data = {
    current_uid: sessionStorage.getItem("a"),
    addon_id: idInput.val() !== "" ? idInput.val() : undefined,
    addon_code: codeInput.val(),
    addon_desc: descInput.val(),
    remark: remarkInput.val(),
    amt: amtInput.val(),
    display_seq: displaySeqInput.val(),
    is_in_use: isActive,
  };

  console.log(data.addon_id);

  const requestData = {
    current_uid: data.current_uid,
    addon_id: data.addon_id,
    addon_code: data.addon_code,
    addon_desc: data.addon_desc,
    remark: data.remark,
    amt: data.amt,
    display_seq: data.display_seq,
    is_in_use: data.is_in_use,
  };

  $.ajax({
    url: "http://localhost:3500/admin/addon/save",
    method: "POST",
    dataType: "json",
    data: requestData,
    success: function (response) {
      console.log(response);

      if (self.currItem.data.addon_id === undefined) {
        // Create new record
        const newAddonId = response.data.addon_id; // Replace with the actual response key

        const newData = {
          addon_id: newAddonId,
          addon_code: data.addon_code,
          addon_desc: data.addon_desc,
          remark: data.remark,
          amt: data.amt,
          display_seq: data.display_seq,
          is_in_use: data.is_in_use,
        };

        const c2 = ct
          .clone()
          .removeClass("addon-item0")
          .addClass("item-content")
          .data("data", newData);

        c2.find(".addon-code").text(newData.addon_code);
        c2.find(".addon-description").text(newData.addon_desc);
        c2.find(".remark-input").text(newData.remark);
        c2.find(".modified-on").text(formatDateTime(response.data.modified_on));
        c2.find(".modified-by").text(response.data.modified_by);

        self.currItem = { item: c2, data: newData }; // Use the saved 'self' context
        console.log(self.currItem);
        addonList.prepend(c2);
      } else {
        // Update existing record
        self.currItem.data.addon_code = data.addon_code;
        self.currItem.data.addon_desc = data.addon_desc;
        self.currItem.data.remark = data.remark;
        self.currItem.data.amt = data.amt;
        self.currItem.data.display_seq = data.display_seq;
        self.currItem.data.modified_on = response.data.modified_on;
        self.currItem.data.modified_by = response.data.modified_by;

        self.currItem.item
          .find(".addon-code")
          .text(self.currItem.data.addon_code);
        self.currItem.item
          .find(".addon-description")
          .text(self.currItem.data.addon_desc);
        self.currItem.item
          .find(".remark-input")
          .text(self.currItem.data.remark);
        self.currItem.item.find(".amt-input").text(self.currItem.data.amt);
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

SetAddon.prototype.resetInputFields = function () {
  $(
    ".addon-code-input, .addon-desc-input, .remark-input, .amt-input, .display-seq-input"
  ).val("");
  $(".is-active-input").removeClass("btn-checkbox");
  $(".is-active-input").addClass("btn-checkbox0");
  this.currItem = { item: null, data: {} };
};

// Delete
SetAddon.prototype.handleAddonItemRemove = function (e) {
  const item = $(e.currentTarget).closest(".item-content");
  console.log(item);
  const addonId = item.data("data").addon_id;
  console.log(addonId);

  const self = this;
  $.ajax({
    url: "http://localhost:3500/admin/addon/delete", // Update the URL according to your backend endpoint for deleting an addon
    method: "POST",
    dataType: "json",
    data: {
      current_uid: sessionStorage.getItem("a"),
      addon_id: addonId,
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

      item.fadeOut(100, () => {
        item.remove();
      });
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
  const setAddon = new SetAddon();
  setAddon.init();
});
