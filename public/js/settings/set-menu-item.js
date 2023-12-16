"use strict";

function SetMenuItem() {
  this.currItem = { item: null, data: {} };
  this.prodId = undefined;
}

const backButton = document.querySelector(".btn-back0");

// Add event listener to the button
backButton.addEventListener("click", function () {
  // Navigate to settings.html
  window.location.href = "/admin/settings";
});

const addButton = document.querySelector(".btn-add");

addButton.addEventListener("click", function () {
  window.location.href = "/admin/menu_item/add_product";
});

function toggleCheckbox(checkbox) {
  checkbox.classList.toggle("btn-checkbox");
  checkbox.classList.toggle("btn-checkbox0");
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

SetMenuItem.prototype.init = function() {
  const self = this;
  $.ajax({
    url: "http://localhost:3500/admin/menu_item/list", 
    method: "POST",
    dataType: "json",
    data: {
      axn: "setup",
    },
    success: function (response) {
      console.log(response);
      console.log(response.recordsets);
      const data = response.recordsets[1]
      console.log(data);

      const menuItem = $(".menu-item");
      menuItem.empty();
      const cloneMenuItem = $(".menu-item0");

      data.forEach(function(menu) {
          const c2 = cloneMenuItem
            .clone()
            .removeClass("menu-item0")
            .addClass("item-line")
            .data("data", menu);
          console.table(menu);

          c2.find(".prod-desc").text(menu.prod_desc)
          c2.find(".type").text(menu.prod_type_desc)
          c2.find(".category").text(menu.prod_cat_desc)
          c2.find(".group").text(menu.prod_group_desc)
          c2.find(".price").text(`RM ${menu.price.toFixed(2)}`)
          c2.find(".last-modified-on").text(formatDateTime(menu.modified_on))
          c2.find(".last-modified-by").text(menu.modified_by)

          menuItem.append(c2)
      })
      menuItem.on(
        "click",
        ".item-line",
        self.handleClickItem.bind(self)
      );
    },
    error: function (xhr, status, error) {
      // Handle any errors that occurred during the request
      console.error(error);
    },
  });
}

SetMenuItem.prototype.handleClickItem = function(e) {
  const item = $(e.currentTarget).closest(".item-line");
  const data = item.data("data");
  console.log(data);

  window.location.href=`http://localhost:3500/admin/menu_item/add_product?id=${data.prod_id}`
}

//--------------------------------------//
//        Page Startup Function         //
//--------------------------------------//
$(() => {
  const setMenuItem = new SetMenuItem();
  setMenuItem.init();
});