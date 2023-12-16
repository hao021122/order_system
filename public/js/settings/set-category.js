"use strict";

function SetCategory() {
  this.currItem = { item: null, data: {} };
  this.categoryId = undefined;
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

// List
// function fetchData() {
//   $.ajax({
//     url: "http://localhost:3500/category", // Update the URL according to your backend endpoint
//     method: "POST",
//     dataType: "json",
//     data: {
//       axn: "setup",
//     },
//     success: function (response) {
//       // Handle the successful response from the backend
//       console.log(response);
//       console.log(response.recordsets);

//       // Update the UI with the retrieved data
//       var itemList = $(".item-list");
//       var content = response.recordsets;
//       var data = JSON.stringify(content);
//       console.log(data);
//       // Clear the existing content in the item list
//       itemList.empty();

//       // Iterate over the retrieved addons and generate HTML for each addon
//       content.forEach(function (categoryArray) {
//         categoryArray.forEach(function (category) {
//           var categoryItem = $('<div class="category-item"></div>');

//           // Store the addon ID as a data attribute on the addon item
//           categoryItem.data("data", category);
//           console.log(category);
//           // Create and append the UI elements for the desired data fields
//           // $(
//           //   '<div class="cat-id" style="display:none;">' +
//           //     category.prod_cat_id +
//           //     "</div>"
//           // ).appendTo(categoryItem);
//           $(
//             '<div class="cat-desc">' + category.prod_cat_desc + "</div>"
//           ).appendTo(categoryItem);
//           // $(
//           //   '<div class="cat-display-seq" style="display:none;">' +
//           //     category.display_seq +
//           //     "</div>"
//           // ).appendTo(categoryItem);
//           $(
//             '<div class="modified-on">' + category.modified_on + "</div>"
//           ).appendTo(categoryItem);
//           $(
//             '<div class="modified-by">' + category.modified_by + "</div>"
//           ).appendTo(categoryItem);

//           // Add more UI elements as needed

//           // Append the addon item to the item list
//           itemList.append(categoryItem);
//           console.log(categoryItem);
//         });
//       });
//     },
//     error: function (xhr, status, error) {
//       // Handle any errors that occurred during the request
//       console.error(error);
//     },
//   });
// }
// Call the fetchData function immediately to fetch data on page load
//fetchData();
// Run the fetchData function every 10 seconds
// setInterval(fetchData, 10000);

// Filter the sreach
SetCategory.prototype.handleCategoryItemFilter = function () {
  const fields = $(".search-description").val().toUpperCase();

  $(".item-content").each(function () {
    const name = $(this).find(".cat-desc").text().toUpperCase();
    $(this).toggle(name.includes(fields));
  });
};

SetCategory.prototype.init = function () {
  const self = this;
  $.ajax({
    url: "http://localhost:3500/admin/category/list",
    method: "POST",
    dataType: "json",
    data: {
      axn: "setup",
    },
    success: function (response) {
      console.log(response);
      const data = response.recordsets;
      console.log(data);
      const categoryItem = $(".item-list");
      categoryItem.empty();
      const cloneCategoryItem = $(".category-item0");

      data.forEach(function (itemArray) {
        itemArray.forEach(function (item) {
          const c2 = cloneCategoryItem
            .clone()
            .removeClass("category-item0")
            .addClass("item-content")
            .data("data", item);
          console.table(item);

          c2.find(".cat-desc").text(item.prod_cat_desc);
          c2.find(".modified-on").text(formatDateTime(item.modified_on));
          c2.find(".modified-by").text(item.modified_by);

          categoryItem.append(c2);
        });
        categoryItem.on(
          "click",
          ".item-content",
          self.handleCategoryItemClick.bind(self)
        );
        categoryItem.on(
          "click",
          ".btn-delete",
          self.handleCategoryItemRemove.bind(self)
        );
      });
    },
    error: function () {
      console.log("An error has occurred.");
    },
  });

  $(".search-description").on("keyup", function () {
    self.handleCategoryItemFilter();
  });

  $(".btn-add").on("click", function () {
    self.resetInputFields();
  });

  $(".btn-save").on("click", function () {
    self.handleCategoryItemSave();
  });
};

// $(document).on("click", ".category-item", function () {
//   var c0 = $(this).data("data");
//   console.log(c0);
//   // Get the clicked addon's content
//   var categoryId = c0.prod_cat_id;
//   var isActive = c0.is_in_use;
//   // Set the content in the HTML input tags
//   $(".prod-cat-id-input").val(categoryId);
//   $(".prod-cat-desc-input").val(c0.prod_cat_desc);
//   $(".display-seq-input").val(c0.display_seq);
//   var isCheckboxActive = isActive === 1;
//   $(".is-active-input").toggleClass("btn-checkbox", isCheckboxActive);
//   $(".is-active-input").toggleClass("btn-checkbox0", !isCheckboxActive);
// });

SetCategory.prototype.handleCategoryItemClick = function (e) {
  console.log(11);
  const item = $(e.currentTarget).closest(".item-content");
  const data = item.data("data");
  console.log(data);
  this.currItem = { item, data };

  $(".prod-cat-id-input").val(data.prod_cat_id);
  $(".prod-cat-desc-input").val(data.prod_cat_desc);
  $(".display-seq-input").val(data.display_seq);
  var isCheckboxActive = data.is_in_use === 1;
  $(".is-active-input")
    .toggleClass("btn-checkbox", isCheckboxActive)
    .toggleClass("btn-checkbox0", !isCheckboxActive);
};

// $(document).on("click", ".btn-add", function (e) {
//   e.preventDefault();

//   // Retrieve the input values
//   $(".prod-cat-id-input").val("");
//   $(".prod-cat-desc-input").val("");
//   $(".display-seq-input").val("");
//   $(".is-active-input").removeClass("btn-checkbox");
//   $(".is-active-input").addClass("btn-checkbox0");
// });

SetCategory.prototype.resetInputFields = function () {
  $(".prod-cat-id-input, .prod-cat-desc-input, .display-seq-input").val("");
  $(".is-active-input").removeClass("btn-checkbox");
  $(".is-active-input").addClass("btn-checkbox0");
  this.currItem = { item: null, data: {} };
};

// $(document).on("click", ".btn-save", function (e) {
//   e.preventDefault();

//   // Retrieve the input values
//   var categoryId = $(".prod-cat-id-input").val();
//   var categoryDescription = $(".prod-cat-desc-input").val();
//   var displaySequence = $(".display-seq-input").val();
//   var isActive = $(".is-active-input").hasClass("btn-checkbox") ? "1" : "0";
//   console.log(categoryId);
//   console.log(categoryDescription);

//   // Create an object with the addon data
//   var categoryData = {
//     categoryId: categoryId !== "" ? categoryId : undefined,
//     categoryDescription: categoryDescription,
//     displaySequence: displaySequence,
//     isActive: isActive,
//   };

//   // Perform an AJAX request to create the addon
//   $.ajax({
//     url: "http://localhost:3500/category/save", // Update the URL according to your backend endpoint for creating an addon
//     method: "POST",
//     dataType: "json",
//     data: {
//       current_uid: "admin",
//       prod_cat_id: categoryData.categoryId,
//       prod_cat_desc: categoryData.categoryDescription,
//       display_seq: categoryData.displaySequence,
//       is_in_use: categoryData.isActive,
//     },
//     success: function (response) {
//       // Handle the successful response from the backend
//       console.log(response);
//       // Clear the input fields
//       $(".prod-cat-id-input").val("");
//       $(".prod-cat-desc-input").val("");
//       $(".display-seq-input").val("");
//       $(".is-active-input").removeClass("is-active");
//       console.log(response.data.result);
//       // Show Popup
//       if (response.data.result === "OK") {
//         var successMsg = "The record have been saved.";
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
//       // Handle any errors that occurred during the request
//       console.error(error);
//     },
//   });
// });
SetCategory.prototype.handleCategoryItemSave = function () {
  const idInput = $(".prod-cat-id-input");
  const descInput = $(".prod-cat-desc-input");
  const displaySeqInput = $(".display-seq-input");
  const isActive = $(".is-active-input").hasClass("btn-checkbox") ? "1" : "0";

  const ct = $(".category-item0");
  const categoryList = $(".item-list");
  const self = this;

  const data = {
    current_uid: sessionStorage.getItem("a"),
    prod_cat_id: idInput.val() !== "" ? idInput.val() : undefined,
    prod_cat_desc: descInput.val(),
    display_seq: displaySeqInput.val(),
    is_in_use: isActive,
  };

  console.log(data.prod_cat_id);

  const requestData = {
    current_uid: data.current_uid,
    prod_cat_id: data.prod_cat_id,
    prod_cat_desc: data.prod_cat_desc,
    display_seq: data.display_seq,
    is_in_use: data.is_in_use,
  };

  $.ajax({
    url: "http://localhost:3500/admin/category/save",
    method: "POST",
    dataType: "json",
    data: requestData,
    success: function (response) {
      console.log(response);

      if (self.currItem.data.prod_cat_id === undefined) {
        // Create new record
        const newCategoryId = response.data.prod_cat_id; // Replace with the actual response key

        const newData = {
          prod_cat_id: newCategoryId,
          prod_cat_desc: data.prod_cat_desc,
          display_seq: data.display_seq,
          is_in_use: data.is_in_use,
        };

        const c2 = ct
          .clone()
          .removeClass("category-item0")
          .addClass("item-content")
          .data("data", newData);

        c2.find(".cat-desc").text(newData.prod_cat_desc);
        c2.find(".display-seq-input").text(newData.display_seq);
        c2.find(".modified-on").text(formatDateTime(response.data.modified_on));
        c2.find(".modified-by").text(response.data.modified_by);

        self.currItem = { item: c2, data: newData }; // Use the saved 'self' context
        console.log(self.currItem);
        categoryList.prepend(c2);
      } else {
        // Update existing record
        self.currItem.data.prod_cat_desc = data.prod_cat_desc;
        self.currItem.data.display_seq = data.display_seq;
        self.currItem.data.modified_on = response.data.modified_on;
        self.currItem.data.modified_by = response.data.modified_by;

        self.currItem.item
          .find(".cat-desc")
          .text(self.currItem.data.prod_cat_desc);
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
SetCategory.prototype.handleCategoryItemRemove = function (e) {
  const item = $(e.currentTarget).closest(".item-content");
  console.log(item);
  const categoryId = item.data("data").prod_cat_id;
  console.log(categoryId);

  const self = this;
  $.ajax({
    url: "http://localhost:3500/admin/category/delete", // Update the URL according to your backend endpoint for deleting an addon
    method: "POST",
    dataType: "json",
    data: {
      current_uid: sessionStorage.getItem("a"),
      prod_cat_id: categoryId,
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
  const setCategory = new SetCategory();
  setCategory.init();
});
