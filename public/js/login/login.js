"use strict";

// document.getElementById("login-form").addEventListener("submit", function (e) {
//   e.preventDefault();

//   var usernameInput = $(".user-login-id-input");
//   var passwordInput = $(".user-password-input");

//   var enteredUsername = usernameInput.val();
//   var enteredPassword = passwordInput.val();

//   $.ajax({
//     url: "http://localhost:3500/order_auth/auth",
//     method: "POST",
//     dataType: "json",
//     data: {
//       uid: enteredUsername,
//       pwd: enteredPassword,
//     },
//     success: function (response) {
//       console.log(response);
//       const data = response.recordsets;
//       console.log(data);

//       // Check the response for successful authentication
//       // if (response.success) {
//       //   // Redirect to the home page or perform any desired actions upon successful login
//       //   window.location.href = "/modules/admin/dashboard.html";
//       // } else {
//       //   showPopupMessage("Invalid username or password.");
//       // }
//     },
//     error: function (xhr, status, error) {
//       // Handle any errors that occurred during the request
//       console.error(error);
//     },
//   });
// });

document.getElementById("login-form").addEventListener("submit", function (e) {
  e.preventDefault();

  var usernameInput = $(".user-login-id-input");
  var passwordInput = $(".user-password-input");

  var enteredUsername = usernameInput.val();
  var enteredPassword = passwordInput.val();

  $.ajax({
    url: "http://localhost:3500/order_auth/auth",
    method: "POST",
    dataType: "json",
    data: {
      uid: enteredUsername,
      pwd: enteredPassword,
    },
    success: function (response) {
      console.log(response);
      console.log(response.result.output.result);
      console.log(response.result.output.login_id);
      // Check the "result" property in "result1" for authentication status

      if (response.result.output.result === "OK") {
        // Authentication successful
        // You can access the password check result with response.result1.output.pwd_check
        // and the session ID with response.result2.output.sess_uid
        // For example, you can store these values in localStorage or perform other actions
        // Redirect to the home page or perform any desired actions upon successful login
        $("#cur_id").val(response.result.output.login_id);
        sessionStorage.setItem("a", response.result.output.login_id);
        sessionStorage.setItem("sess_uid", response.result.output.sess_uid);

        if (response.result2 !== "75075FC3-05F2-46F1-964D-4F2003E2A439") {
          window.location.href = "/admin/dashboard";
        } else {
          window.location.href = "/order";
        }
      }
      // else {
      //   // Authentication failed
      //   // Show an error message to the user
      //   showPopupMessage("Invalid username or password.");
      // }
    },
    error: function (xhr, status, error) {
      // Handle any errors that occurred during the request
      if (xhr.status === 401) {
        // HTTP status code is 401 (Unauthorized)
        showPopupMessage("Invalid username or password.");

        usernameInput.val("");
        passwordInput.val("");
      } else {
        console.error(error);
      }
    },
  });
});

function showPopupMessage(message) {
  var popupContainer = document.getElementById("popup-container");
  var popupMessage = document.getElementById("popup-message");

  // Set the message content
  popupMessage.textContent = message;

  // Show the popup container
  popupContainer.style.display = "block";
}

document
  .getElementById("popup-close-btn")
  .addEventListener("click", function () {
    hidePopup();
  });

function hidePopup() {
  var popupContainer = document.getElementById("popup-container");

  // Hide the popup container
  popupContainer.style.display = "none";
}
