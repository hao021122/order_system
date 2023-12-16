"use strict";

const backButton = document.querySelector(".btn-back0");

// Add event listener to the button
backButton.addEventListener("click", function () {
  // Navigate to settings.html
  window.location.href = "/admin/settings";
});

$.ajax({
  url: "http://localhost:3500/admin/quotation_setting/list", // Update the URL according to your backend endpoint
  method: "POST",
  dataType: "json",
  data: {},
  success: function (response) {
    // Handle the successful response from the backend
    console.log(response);
    console.log(response.recordsets);

    var content = response.recordsets[0][0];
    var quotationHeader = content.receipt_header;
    var quotationFooter = content.receipt_footer;
    var blankLine = content.no_of_blank_line;
    // console.log(content);
    // console.log(content.receipt_header);
    // Update input
    $(".quotation-header-input").val(quotationHeader);
    $(".quotation-footer-input").val(quotationFooter);
    $(".no-of-blank-line-input").val(blankLine);
  },
  error: function (xhr, status, error) {
    // Handle any errors that occurred during the request
    console.error(error);
  },
});

$(document).on("click", ".btn-save", function (e) {
  e.preventDefault();

  // Retrieve the input values
  // var addonId =
  //   var quotationId = $(".prod-cat-id-input").val();
  //   var quotationIdValue = quotationId.length === 36 ? quotationId : null;
  var quotationHeader = $(".quotation-header-input").val();
  var quotationFooter = $(".quotation-footer-input").val();
  var blankLine = $(".no-of-blank-line-input").val();
  //   console.log(quotationId);
  //   console.log(quotationDescription);

  // Create an object with the addon data
  var quotationData = {
    quotationHeader: quotationHeader,
    quotationFooter: quotationFooter,
    blankLine: blankLine,
  };

  console.log(quotationData);

  // Perform an AJAX request to create the addon
  $.ajax({
    url: "http://localhost:3500/admin/quotation_setting/save", // Update the URL according to your backend endpoint for creating an addon
    method: "POST",
    dataType: "json",
    data: {
      current_uid: sessionStorage.getItem("a"),
      receipt_header: quotationData.quotationHeader,
      receipt_footer: quotationData.quotationFooter,
      no_of_blank_line: quotationData.blankLine,
    },
    success: function (response) {
      // Handle the successful response from the backend
      console.log(response);

      console.log(response.output.result);
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
