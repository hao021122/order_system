"use strict";

function setSeason() {}

const backButton = document.querySelector(".btn-back0");

// Add event listener to the button
backButton.addEventListener("click", function () {
  // Navigate to settings.html
  window.location.href = "/client-order/order/modules/admin/settings.html";
});

function toggleCheckbox(checkbox) {
  $(checkbox).toggleClass("btn-checkbox btn-checkbox0");
}

function formatDate(dateFormat) {
  var date = new Date(dateFormat);

  var day = date.getDate().toString().padStart(2, "0");
  var month = (date.getMonth() + 1).toString().padStart(2, "0");
  var year = date.getFullYear();

  var fullDate = year + "-" + month + "-" + day;
  return fullDate;
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

$.ajax({
  url: "http://localhost:3500/season", // Update the URL according to your backend endpoint
  method: "POST",
  dataType: "json",
  data: {
    axn: "setup",
  },
  success: function (response) {
    // Handle the successful response from the backend
    console.log(response);
    console.log(response.recordsets);

    // Update the UI with the retrieved data
    var itemList = $(".item-list");
    var content = response.recordsets;
    var data = JSON.stringify(content);
    console.log(data);
    // Clear the existing content in the item list
    itemList.empty();

    // Iterate over the retrieved addons and generate HTML for each addon
    content.forEach(function (seasonArray) {
      seasonArray.forEach(function (season) {
        var seasonItem = $('<div class="season-item"></div>');

        // Store the addon ID as a data attribute on the addon item
        seasonItem.data("data", season);
        console.log(season);
        // Create and append the UI elements for the desired data fields
        // $(
        //   '<div class="season-id" style="display:none;">' +
        //     season.season_id +
        //     "</div>"
        // ).appendTo(seasonItem);
        $('<div class="season-desc">' + season.season_desc + "</div>").appendTo(
          seasonItem
        );
        // $(
        //   '<div class="msg-on-screen" style="display:none;">' +
        //     season.msg_on_screen +
        //     "</div>"
        // ).appendTo(seasonItem);
        // $(
        //   '<div class="season-display-seq" style="display:none;">' +
        //     season.display_seq +
        //     "</div>"
        // ).appendTo(seasonItem);
        $(
          '<div class="modified-on">' +
            formatDateTime(season.modified_on) +
            "</div>"
        ).appendTo(seasonItem);
        $('<div class="modified-by">' + season.modified_by + "</div>").appendTo(
          seasonItem
        );

        // Add more UI elements as needed

        // Append the addon item to the item list
        itemList.append(seasonItem);
        console.log(seasonItem);
      });
    });
  },
  error: function (xhr, status, error) {
    // Handle any errors that occurred during the request
    console.error(error);
  },
});

$(document).on("click", ".season-item", function () {
  var c0 = $(this).data("data");
  console.log(c0);
  var seasonId = c0.season_id;
  var isActive = c0.is_in_use;

  // Set the content in the HTML input tags
  $(".season-id-input").val(seasonId);
  $(".season-input").val(c0.season_desc);
  $(".start-date-input").val(formatDate(c0.start_dt));
  $(".end-date-input").val(formatDate(c0.end_dt));
  $(".msg-on-screen-input").val(c0.msg_on_screen);
  $(".display-seq-input").val(c0.display_seq);
  var isCheckboxActive = isActive === 1;
  $(".is-active-input").toggleClass("btn-checkbox", isCheckboxActive);
  $(".is-active-input").toggleClass("btn-checkbox0", !isCheckboxActive);
});

$(document).on("click", ".btn-add", function (e) {
  e.preventDefault();

  // Retrieve the input values
  $(".season-id-input").val("");
  $(".season-input").val("");
  $(".start-date-input").val("");
  $(".end-date-input").val("");
  $(".msg-on-screen-input").val("");
  $(".display-seq-input").val("");
  $(".is-active-input").removeClass("btn-checkbox");
  $(".is-active-input").addClass("btn-checkbox0");
});

$(document).on("click", ".btn-save", function (e) {
  e.preventDefault();

  var seasonId = $(".season-id-input").val();
  var season = $(".season-input").val();
  var startDt = $(".start-date-input").val();
  var endDt = $(".end-date-input").val();
  var msgOnScreen = $(".msg-on-screen-input").val();
  var displaySeq = $(".display-seq-input").val();
  var isActive = $(".is-active-input").hasClass("btn-checkbox") ? "1" : "0";

  var seasonData = {
    seasonId: seasonId !== "" ? seasonId : undefined,
    season: season,
    startDt: startDt,
    endDt: endDt,
    msgOnScreen: msgOnScreen,
    displaySeq: displaySeq,
    isActive: isActive,
  };

  $.ajax({
    url: "http://localhost:3500/season/save",
    method: "POST",
    dataType: "JSON",
    data: {
      current_uid: "admin",
      season_id: seasonData.seasonId,
      season_desc: seasonData.season,
      start_dt: seasonData.startDt,
      end_dt: seasonData.endDt,
      msg_on_screen: seasonData.msgOnScreen,
      display_seq: seasonData.displaySeq,
      is_in_use: seasonData.isActive,
    },
    success: function (response) {
      console.log(response);

      $(".season-id-input").val("");
      $(".season-input").val("");
      $(".start-date-input").val("");
      $(".end-date-input").val("");
      $(".msg-on-screen-input").val();
      $(".display-seq-input").val();
      $(".is-active-input").removeClass("is-active");
      // Show Popup
      if (response.output.result === "OK") {
        var successMsg = "The record have been saved.";
        $("#popup-message").text(successMsg);
        $("#popup-container").show();
      } else {
        $("#popup-message").text(response.output.result);
        $("#popup-container").show();
      }
      $("#popup-close-btn").on("click", function () {
        $("#popup-container").hide();
      });
    },
    error: function (xhr, status, error) {
      // Handle any errors that occurred during the request
      console.error(error);
    },
  });
});

$(document).on("click", ".btn-delete", function (e) {
  e.preventDefault();

  // Retrieve the addon ID from the clicked element or any other source
  var seasonId = $(".season-id-input").val();
  console.log(seasonId);
  // Perform an AJAX request to delete the addon
  $.ajax({
    url: "http://localhost:3500/season/delete", // Update the URL according to your backend endpoint for deleting an addon
    method: "POST",
    dataType: "json",
    data: {
      current_uid: "admin",
      season_id: seasonId,
    },
    success: function (response) {
      // Handle the successful response from the backend
      console.log(response);
      // Perform any additional actions after deleting the addon
      // Show Popup
      if (response.output.result === "OK") {
        var successMsg = "The record has been deleted.";
        $("#popup-message").text(successMsg);
        $("#popup-container").show();
      } else {
        $("#popup-message").text(response.output.result);
        $("#popup-container").show();
      }
      $("#popup-close-btn").on("click", function () {
        $("#popup-container").hide();
      });
    },
    error: function (xhr, status, error) {
      // Handle any errors that occurred during the request
      console.error(error);
    },
  });
});
