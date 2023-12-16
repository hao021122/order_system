"use-strict";

$(document).on("click", ".logout", function () {
  console.log("I am logout!!");

  var sess_uid = sessionStorage.getItem("sess_uid");

  $.ajax({
    url: "http://localhost:3500/order_auth/logout",
    method: "POST",
    dataType: "json",
    data: {
      sess_uid: sess_uid,
    },
    success: function (response) {
      console.log(response);
      sessionStorage.removeItem("sess_uid");
      sessionStorage.removeItem("a");
      window.location.href = "/";
    },
    error: function (xhr, status, error) {
      // Handle any errors that occurred during the request
      console.error(error);
    },
  });
});
