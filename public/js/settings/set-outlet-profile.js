"use strict";

const backButton = document.querySelector(".btn-back0");

// Add event listener to the button
backButton.addEventListener("click", function () {
  // Navigate to settings.html
  window.location.href = "/admin/settings";
});

function toggleCheckbox(checkbox) {
  checkbox.classList.toggle("btn-checkbox");
  checkbox.classList.toggle("btn-checkbox0");
}

$.ajax({
  url: "http://localhost:3500/admin/outlet/list", // Update the URL according to your backend endpoint
  method: "POST",
  dataType: "json",
  data: {},
  success: function (response) {
    // Handle the successful response from the backend
    console.log(response);
    console.log(response.recordsets);

    var content = response.recordsets[0][0];
    var outletName = content.co_name;
    var address1 = content.addr1;
    var address2 = content.addr2;
    var postcode = content.postcode;
    var city = content.city;
    var state = content.state;
    var country = content.country;
    var phone = content.phone;
    var email = content.email;

    // console.log(content);
    // console.log(content.receipt_header);
    // Update input
    $(".co-name-input").val(outletName);
    $(".addr1-input").val(address1);
    $(".addr2-input").val(address2);
    $(".postcode-input").val(postcode);
    $(".city-input").val(city);
    $(".state-input").val(state);
    $(".country-input").val(country);
    $(".phone-input").val(phone);
    $(".email-input").val(email);
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
  var outletName = $(".co-name-input").val();
  var address1 = $(".addr1-input").val();
  var address2 = $(".addr2-input").val();
  var postcode = $(".postcode-input").val();
  var city = $(".city-input").val();
  var state = $(".state-input").val();
  var country = $(".country-input").val();
  var phone = $(".phone-input").val();
  var email = $(".email-input").val();

  // Create an object with the addon data
  var outletData = {
    outletName: outletName,
    address1: address1,
    address2: address2,
    postcode: postcode,
    city: city,
    state: state,
    country: country,
    phone: phone,
    email: email,
  };
  console.log(outletData);

  // Perform an AJAX request to create the addon
  $.ajax({
    url: "http://localhost:3500/admin/outlet/save", // Update the URL according to your backend endpoint for creating an addon
    method: "POST",
    dataType: "json",
    data: {
      current_uid: sessionStorage.getItem("a"),
      co_name: outletData.outletName,
      addr1: outletData.address1,
      addr2: outletData.address2,
      postcode: outletData.postcode,
      city: outletData.city,
      state: outletData.state,
      country: outletData.country,
      phone: outletData.phone,
      email: outletData.email,
    },
    success: function (response) {
      // Handle the successful response from the backend
      console.log(response);
      // Clear the input fields
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
