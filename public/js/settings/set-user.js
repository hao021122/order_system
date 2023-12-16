"use-strict";

function SetUser() {
  this.currItem = { item: null, data: {} };
  this.userId = undefined;
}

const backButton = document.querySelector(".btn-back0");

// Add event listener to the button
backButton.addEventListener("click", function () {
  // Navigate to settings.html
  window.location.href = "/admin/settings";
});

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

function toggleCheckbox(checkbox) {
  $(checkbox).toggleClass("btn-checkbox btn-checkbox0");
}

SetUser.prototype.handleUserListFilter = function () {
  const filter = $(".search-description").val().toUpperCase();

  $(".item-content").each(function () {
    const name = $(this).find(".username").text().toUpperCase();
    $(this).toggle(name.includes(filter));
  });
};

SetUser.prototype.handleUserListOnClick = function (e) {
  const item = $(e.currentTarget).closest(".item-content");
  const data = item.data("data");
  console.table(data);
  this.currItem = { item, data };

  $(".username-input").val(data.name);
  $(".login-id-input").val(data.login_id);
  $(".user-type-desc-input").val(data.user_type_desc);
  $(".user-group-desc-input").val(data.user_group_desc);
  var isCheckboxActive = data.user_status === 1;
  $(".is-active-input")
    .toggleClass("btn-checkbox", isCheckboxActive)
    .toggleClass("btn-checkbox0", !isCheckboxActive);
};

SetUser.prototype.handleUserItemSave = function () {
  const idInput = $(".user-id-input");
  const userNameInput = $(".username-input");
  const loginIdInput = $(".login-id-input");
  const pwdInput = $(".pwd-input");
  const typeInput = $(".user-type-id-input");
  const groupInput = $(".user-group-id-input");
  const isActive = $(".is-active-input").hasClass("btn-checkbox") ? "1" : "0";

  const ct = $(".user-item0");
  const userList = $(".item-list");
  const self = this;

  const data = {
    user_id: idInput.val() !== "" ? idInput.val() : undefined,
    user_name: userNameInput.val(),
    login_id: loginIdInput.val(),
    pwd: pwdInput.val(),
    user_type_id: typeInput.val(),
    ids: groupInput.val(),
    user_status_id: isActive,
  };

  const requestData = {
    user_id: data.user_id,
    user_name: data.user_name,
    login_id: data.login_id,
    pwd: data.pwd,
    user_type_id: data.user_type_id,
    ids: data.ids,
    user_status_id: isActive,
  };

  $.ajax({
    url: "http://localhost:3500/admin/users/save",
    method: "POST",
    dataType: "json",
    data: requestData,
    success: function (response) {
      console.log(response);

      if (self.currItem.data.user_id === undefined) {
        // Create new record
        const newUserId = response.response1.data.user_id; // Replace with the actual response key

        const newData = {
          user_id: newUserId,
          login_id: data.login_id,
          user_name: data.user_name,
          pwd: data.pwd,
          user_type_id: data.user_type_id,
          ids: data.ids,
          user_status_id: data.user_status_id,
        };

        const c2 = ct
          .clone()
          .removeClass("user-item0")
          .addClass("item-content")
          .data("data", newData);

        c2.find(".username").text(newData.user_name);
        c2.find(".login-id").text(newData.login_id);
        c2.find(".user-status-desc").text(newData.user_status_desc);
        c2.find(".last-access-on").text(formatDateTime(newData.last_access_on));

        self.currItem = { item: c2, data: newData }; // Use the saved 'self' context
        console.log(self.currItem);
        userList.prepend(c2);
      } else {
        // Update existing record
        self.currItem.data.user_name = data.user_name;
        self.currItem.data.login_id = data.login_id;
        self.currItem.data.user_type_id = data.user_type_id;
        self.currItem.data.user_type_desc = data.user_type_desc;
        self.currItem.data.user_group_id = data.user_group_id;
        self.currItem.data.user_group_desc = data.user_group_desc;
        self.currItem.data.user_status_id = data.user_status_id;
        self.currItem.data.user_status_desc = data.user_status_desc;
        self.currItem.data.last_access_on = data.last_access_on;

        self.currItem.item.find(".username").text(self.currItem.data.user_name);
        self.currItem.item.find(".login-id").text(self.currItem.data.login_id);
        self.currItem.item
          .find(".user-type-id-input")
          .text(self.currItem.data.user_type_id);
        self.currItem.item
          .find(".user-type-desc-input")
          .text(self.currItem.data.user_type_desc);
        self.currItem.item
          .find(".user-group-id-input")
          .text(self.currItem.data.user_group_id);
        self.currItem.item
          .find(".user-group-desc-input")
          .text(formatDateTime(self.currItem.data.user_group_desc));
        self.currItem.item
          .find(".user-status-id-input")
          .text(self.currItem.data.user_status_id);
        self.currItem.item
          .find(".user-status-id-desc")
          .text(self.currItem.data.user_status_desc);
        self.currItem.item
          .find(".last-access-on")
          .text(self.currItem.data.last_access_on);
        self.currItem.item.data("data", self.currItem.data);
      }

      // Show Popup
      if (response.response3.data.result === "OK") {
        var successMsg = "The user has been saved.";
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

SetUser.prototype.init = function () {
  const self = this;

  $.ajax({
    url: "http://localhost:3500/admin/users/list",
    method: "POST",
    dataType: "json",
    data: {
      startRowIndex: 0,
      maximumRows: 100,
      current_uid: sessionStorage.getItem("a"),
    },
    success: function (response) {
      console.log(response);
      const data = response.recordsets;
      console.log(data);
      const userItem = $(".item-list");
      userItem.empty();
      const cloneUserItem = $(".user-item0");

      data.forEach(function (itemArray) {
        itemArray.forEach(function (item) {
          const c2 = cloneUserItem
            .clone()
            .removeClass("user-item0")
            .addClass("item-content")
            .data("data", item);

          c2.find(".username").text(item.name);
          c2.find(".login-id").text(item.login_id);
          c2.find(".user-status-desc").text(item.user_status_desc);
          c2.find(".last-access-on").text(formatDateTime(item.last_access_on));

          userItem.append(c2);
        });

        userItem.on(
          "click",
          ".item-content",
          self.handleUserListOnClick.bind(self)
        );
        userItem.on("click", ".btn-delete", self.handleUserRemove.bind(self));
      });
    },
    error: function (xhr, status, error) {
      console.error(error);
    },
  });

  $(".search-description").on("keyup", function () {
    self.handleUserListFilter();
  });

  $(".btn-save").on("click", function () {
    self.handleUserItemSave();
  });

  $(".btn-add").on("click", function () {
    self.resetInputFields();
  });

  $(".btn-select-user-type, .user-type-desc-input").on("click", function () {
    self.handleUserTypeItem();
  });
  $(".btn-select-user-group, .user-group-desc-input").on("click", function () {
    self.handleUserRoleItem();
  });
};

SetUser.prototype.handleUserTypeItem = function () {
  $.ajax({
    url: "http://localhost:3500/admin/users/t",
    method: "POST",
    dataType: "json",
    data: {
      current_uid: sessionStorage.getItem("a"),
    },
    success: function (response) {
      console.log(response);

      // Show the popup
      $("#user-type-input").show();

      // Retrieve and populate the items
      var items = response.recordsets[0]; // Replace with the actual response data structure
      console.log(items);
      var itemContainer = $("#user-type-item");
      itemContainer.empty();
      var cloneTypeItem = $(".user-type0");

      // Add items to the container
      items.forEach(function (item) {
        const c2 = cloneTypeItem
          .clone()
          .removeClass("user-type0")
          .addClass("user-type")
          .data("data", item);
        console.table(item);

        c2.find(".user-type-desc").text(item.user_type_desc);

        itemContainer.append(c2);
      });
      itemContainer.on("click", ".user-type", function (e) {
        SetUser.prototype.handleTypeItemClick.call(this, e);
      });
    },
    error: function (xhr, status, error) {
      // Handle any errors that occurred during the request
      console.error(error);
    },
  });

  $("#user-type-close-btn").on("click", function () {
    $("#user-type-input").hide();
  });
};

SetUser.prototype.handleTypeItemClick = function (e) {
  console.log(11);
  const item = $(e.currentTarget).closest(".user-type");
  const data = item.data("data");
  console.log(data);

  $(".user-type-desc-input").val(data.user_type_desc);
  $(".user-type-id-input").val(data.user_type_id);
};

SetUser.prototype.handleUserRoleItem = function () {
  $.ajax({
    url: "http://localhost:3500/admin/users/g",
    method: "POST",
    dataType: "json",
    data: {
      current_uid: sessionStorage.getItem("a"),
    },
    success: function (response) {
      console.log(response);

      // Show the popup
      $("#user-group-input").show();

      // Retrieve and populate the items
      var items = response.recordsets[0]; // Replace with the actual response data structure
      console.log(items);
      var itemContainer = $("#user-group-item");
      itemContainer.empty();
      var cloneGroupItem = $(".user-group0");

      // Add items to the container
      items.forEach(function (item) {
        const c2 = cloneGroupItem
          .clone()
          .removeClass("user-group0")
          .addClass("user-group")
          .data("data", item);
        console.table(item);

        c2.find(".user-group-desc").text(item.user_group_desc);

        itemContainer.append(c2);
      });
      itemContainer.on("click", ".user-group", function (e) {
        SetUser.prototype.handleRoleItemClick.call(this, e);
      });
    },
    error: function (xhr, status, error) {
      // Handle any errors that occurred during the request
      console.error(error);
    },
  });

  $("#user-group-close-btn").on("click", function () {
    $("#user-group-input").hide();
  });
};

SetUser.prototype.handleRoleItemClick = function (e) {
  console.log(11);
  const item = $(e.currentTarget).closest(".user-group");
  const data = item.data("data");
  console.log(data);

  $(".user-group-desc-input").val(data.user_group_desc);
  $(".user-group-id-input").val(data.user_group_id);
};

SetUser.prototype.resetInputFields = function () {
  $(
    ".user-id-input, .username-input, .login-id-input, .pwd-input, .user-type-id-input, .user-type-desc-input, .user-group-id-input, .user-group-desc-input"
  ).val("");
  $(".is-active-input").removeClass("btn-checkbox");
  $(".is-active-input").addClass("btn-checkbox0");
  this.currItem = { item: null, data: {} };
};

SetUser.prototype.handleUserRemove = function (e) {
  const item = $(e.currentTarget).closest(".item-content");
  console.log(item);
  const userId = item.data("data").user_id;
  console.log(userId);

  const self = this;
  $.ajax({
    url: "http://localhost:3500/admin/users/delete", // Update the URL according to your backend endpoint for deleting an addon
    method: "POST",
    dataType: "json",
    data: {
      current_uid: sessionStorage.getItem("a"),
      delete_user_id: userId,
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

$(() => {
  const setUser = new SetUser();
  setUser.init();
});
