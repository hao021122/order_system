"use-strict";

function SetGroup() {
  this.currItem = { item: null, data: {} };
  this.groupId = undefined;
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

// Filter the sreach
SetGroup.prototype.handleGroupItemFilter = function () {
  const fields = $(".search-description").val().toUpperCase();

  $(".item-content").each(function () {
    const name = $(this).find(".group-desc").text().toUpperCase();
    $(this).toggle(name.includes(fields));
  });
};

SetGroup.prototype.init = function () {
  const self = this;
  $.ajax({
    url: "http://localhost:3500/admin/group/list",
    method: "POST",
    dataType: "json",
    data: {
      axn: "setup",
    },
    success: function (response) {
      console.log(response);
      const data = response.recordsets;
      console.log(data);
      const groupItem = $(".item-list");
      groupItem.empty();
      const cloneGroupItem = $(".group-item0");

      data.forEach(function (itemArray) {
        itemArray.forEach(function (item) {
          const c2 = cloneGroupItem
            .clone()
            .removeClass("group-item0")
            .addClass("item-content")
            .data("data", item);
          console.table(item);

          c2.find(".group-desc").text(item.prod_group_desc);
          c2.find(".modified-on").text(formatDateTime(item.modified_on));
          c2.find(".modified-by").text(item.modified_by);

          groupItem.append(c2);
        });
        groupItem.on(
          "click",
          ".item-content",
          self.handleGroupItemClick.bind(self)
        );
        groupItem.on(
          "click",
          ".btn-delete",
          self.handleGroupItemRemove.bind(self)
        );
      });
    },
    error: function () {
      console.log("An error has occurred.");
    },
  });

  $(".search-description").on("keyup", function () {
    self.handleGroupItemFilter();
  });

  $(".btn-add").on("click", function () {
    self.resetInputFields();
  });

  $(".btn-save").on("click", function () {
    self.handleGroupItemSave();
  });
};

SetGroup.prototype.handleGroupItemClick = function (e) {
  console.log(11);
  const item = $(e.currentTarget).closest(".item-content");
  const data = item.data("data");
  console.log(data);
  this.currItem = { item, data };

  $(".prod-group-id-input").val(data.prod_group_id);
  $(".prod-group-desc-input").val(data.prod_group_desc);
  $(".display-seq-input").val(data.display_seq);
  var isCheckboxActive = data.is_in_use === 1;
  $(".is-active-input")
    .toggleClass("btn-checkbox", isCheckboxActive)
    .toggleClass("btn-checkbox0", !isCheckboxActive);
};

SetGroup.prototype.resetInputFields = function () {
  $(".prod-group-desc-input, .display-seq-input").val("");
  $(".is-active-input").removeClass("btn-checkbox");
  $(".is-active-input").addClass("btn-checkbox0");
  this.currItem = { item: null, data: {} };
};

// $(document).on("click", ".btn-save", function (e) {
//   e.preventDefault();

//   // Retrieve the input values
//   // var addonId =
//   var groupId = $(".prod-group-id-input").val();
//   var groupDescription = $(".prod-group-desc-input").val();
//   var displaySequence = $(".display-seq-input").val();
//   var isActive = $(".is-active-input").hasClass("btn-checkbox") ? "1" : "0";
//   console.log(groupId);
//   console.log(groupDescription);

//   // Create an object with the addon data
//   var groupData = {
//     groupId: groupId !== "" ? groupId : undefined,
//     groupDescription: groupDescription,
//     displaySequence: displaySequence,
//     isActive: isActive,
//   };

//   console.log(groupData);

//   // Perform an AJAX request to create the addon
//   $.ajax({
//     url: "http://localhost:3500/group/save", // Update the URL according to your backend endpoint for creating an addon
//     method: "POST",
//     dataType: "json",
//     data: {
//       current_uid: "admin",
//       prod_group_id: groupData.groupId,
//       prod_group_desc: groupData.groupDescription,
//       display_seq: groupData.displaySequence,
//       is_in_use: groupData.isActive,
//     },
//     success: function (response) {
//       // Handle the successful response from the backend
//       console.log(response);
//       // Clear the input fields
//       $(".prod-group-id-input").val("");
//       $(".prod-group-desc-input").val("");
//       $(".display-seq-input").val("");
//       $(".is-active-input").removeClass("is-active");
//       console.log(response.output.result);
//       // Perform any additional actions after creating the addon
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

SetGroup.prototype.handleGroupItemSave = function () {
  const idInput = $(".prod-group-id-input");
  const descInput = $(".prod-group-desc-input");
  const displaySeqInput = $(".display-seq-input");
  const isActive = $(".is-active-input").hasClass("btn-checkbox") ? "1" : "0";

  const ct = $(".group-item0");
  const groupList = $(".item-list");
  const self = this;

  const data = {
    current_uid: sessionStorage.getItem("a"),
    prod_group_id: idInput.val() !== "" ? idInput.val() : undefined,
    prod_group_desc: descInput.val(),
    display_seq: displaySeqInput.val(),
    is_in_use: isActive,
  };

  console.log(data.prod_group_id);

  const requestData = {
    current_uid: data.current_uid,
    prod_group_id: data.prod_group_id,
    prod_group_desc: data.prod_group_desc,
    display_seq: data.display_seq,
    is_in_use: data.is_in_use,
  };

  $.ajax({
    url: "http://localhost:3500/admin/group/save",
    method: "POST",
    dataType: "json",
    data: requestData,
    success: function (response) {
      console.log(response);

      if (self.currItem.data.prod_group_id === undefined) {
        // Create new record
        const newGroupId = response.data.prod_group_id; // Replace with the actual response key

        const newData = {
          prod_group_id: newGroupId,
          prod_group_desc: data.prod_group_desc,
          display_seq: data.display_seq,
          is_in_use: data.is_in_use,
        };

        const c2 = ct
          .clone()
          .removeClass("group-item0")
          .addClass("item-content")
          .data("data", newData);

        c2.find(".group-desc").text(newData.prod_group_desc);
        c2.find(".modified-on").text(formatDateTime(response.data.modified_on));
        c2.find(".modified-by").text(response.data.modified_by);

        self.currItem = { item: c2, data: newData }; // Use the saved 'self' context
        console.log(self.currItem);
        groupList.prepend(c2);
      } else {
        // Update existing record
        self.currItem.data.prod_group_desc = data.prod_group_desc;
        self.currItem.data.display_seq = data.display_seq;
        self.currItem.data.modified_on = response.data.modified_on;
        self.currItem.data.modified_by = response.data.modified_by;

        self.currItem.item
          .find(".group-desc")
          .text(self.currItem.data.prod_group_desc);
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

// Delete
SetGroup.prototype.handleGroupItemRemove = function (e) {
  const item = $(e.currentTarget).closest(".item-content");
  console.log(item);
  const groupId = item.data("data").prod_group_id;
  console.log(groupId);

  const self = this;
  $.ajax({
    url: "http://localhost:3500/admin/group/delete", // Update the URL according to your backend endpoint for deleting an addon
    method: "POST",
    dataType: "json",
    data: {
      current_uid: sessionStorage.getItem("a"),
      prod_group_id: groupId,
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
  const setGroup = new SetGroup();
  setGroup.init();
});
