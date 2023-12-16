"use-strict";

function setMailbox() {}

const backButton = document.querySelector(".btn-back0");

// Add event listener to the button
backButton.addEventListener("click", function () {
  // Navigate to settings.html
  window.location.href = "/admin/settings";
});

function toggleCheckbox(checkbox) {
  $(checkbox).toggleClass("btn-checkbox btn-checkbox0");
}

$.ajax({
  url: "http://localhost:3500/admin/mailbox/list", // Update the URL according to your backend endpoint
  method: "POST",
  dataType: "json",
  data: {},
  success: function (response) {
    // Handle the successful response from the backend
    console.log(response);
    console.log(response.recordsets);

    var content = response.recordsets[0][0];
    var smtpServer = content.smtp_server;
    var smtpPort = content.smtp_port;
    //var email = content.smtp_mailbox_uid;
    //var pwd = content.smtp_mailbox_pwd;
    var enableService = content.smtp_disable_service;
    var useSsl = content.smtp_use_ssl;
    // console.log(content);
    // console.log(content.receipt_header);
    // Update input
    $(".server-input").val(smtpServer);
    $(".port-input").val(smtpPort);
    //$(".mailbox-uid-input").val(email);
    //$(".mailbox-pwd-input").val(pwd);
    var isCheckboxActive = enableService === 1;
    $(".enable-smtp-input").toggleClass("btn-checkbox", isCheckboxActive);
    $(".enable-smtp-input").toggleClass("btn-checkbox0", !isCheckboxActive);
    var isCheckboxActive = useSsl === 1;
    $(".use-ssl-input").toggleClass("btn-checkbox", isCheckboxActive);
    $(".use-ssl-input").toggleClass("btn-checkbox0", !isCheckboxActive);
  },
  error: function (xhr, status, error) {
    // Handle any errors that occurred during the request
    console.error(error);
  },
});

$(document).on("click", ".btn-save", function (e) {
  e.preventDefault();

  var smtpServer = $(".server-input").val();
  var smtpPort = $(".port-input").val();
  var email = $(".mailbox-uid-input").val();
  var pwd = $(".mailbox-pwd-input").val();
  var enableService = $(".enable-smtp-input").hasClass("btn-checkbox")
    ? 1
    : "0";
  var useSsl = $(".use-ssl-input").hasClass("btn-checkbox") ? 1 : "0";

  // Create an object with the addon data
  var smtpData = {
    smtpServer: smtpServer,
    smtpPort: smtpPort,
    email: email,
    pwd: pwd,
    enableService: enableService,
    useSsl: useSsl,
  };

  console.log(smtpData);

  // Perform an AJAX request to create the addon
  $.ajax({
    url: "http://localhost:3500/admin/mailbox/save", // Update the URL according to your backend endpoint for creating an addon
    method: "POST",
    dataType: "json",
    data: {
      current_uid: sessionStorage.getItem("a"),
      smtp_server: smtpData.smtpServer,
      smtp_port: smtpData.smtpPort,
      smtp_mailbox_uid: smtpData.email,
      smtp_mailbox_pwd: smtpData.pwd,
      smtp_disable_service: smtpData.enableService,
      smtp_use_ssl: smtpData.useSsl,
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
