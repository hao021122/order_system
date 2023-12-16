"use strict";

function SetProduct() {
}

var addonIds = [];
var requestCode = [];

const backButton = document.querySelector(".btn-back0");

// Add event listener to the button
backButton.addEventListener("click", function () {
  // Navigate to settings.html
  window.location.href = "/admin/menu_item";
});

function toggleCheckbox(checkbox) {
  $(checkbox).toggleClass("btn-checkbox btn-checkbox0");
}

function handleNullOrUndefined(value) {
  return value !== null && value !== undefined ? value : "";
}

function formatDateTime(dateFormat) {
  var date = new Date(dateFormat);

  var day = date.getDate().toString().padStart(2, "0");
  var month = (date.getMonth() + 1).toString().padStart(2, "0");
  var year = date.getFullYear();

  // var hours = date.getHours().toString().padStart(2, "0");
  // var minutes = date.getMinutes().toString().padStart(2, "0");
  // var seconds = date.getSeconds().toString().padStart(2, "0");

  var fullDate = year + "-" + month + "-" + day;
  //var fullTime = hours + ":" + minutes + ":" + seconds;

  return fullDate
}

const urlParams = new URLSearchParams(window.location.search);
const prodId = urlParams.get("id");

SetProduct.prototype.getProdType = function() {
  function handleProductTypeClick() {
    var c0 = $(this).data("data");
    console.log(c0);

    $(".prod-type-input").val(c0.prod_type_desc);
    $(".prod-type-id").val(c0.prod_type_id);
  }

  $.ajax({
    url: "http://localhost:3500/admin/product_type",
    method: "POST",
    dataType: "json",
    data: {
      // Include any necessary data for the request
    },
    success: function (response) {
      // Handle the successful response from the backend
      console.log(response);

      // Show the popup
      $("#product-type").show();

      // Retrieve and populate the items
      var items = response.recordsets; // Replace with the actual response data structure
      var itemContainer = $("#product-type-item");
      itemContainer.empty(); // Clear existing items

      // Add items to the container
      items.forEach(function (typeArray) {
        typeArray.forEach(function (item) {
          var prodType = $('<div class="product-type"></div>');

          prodType.data("data", item);
          $(
            '<div class="id" style="display:none;">' +
              item.prod_type_id +
              "</div>"
          ).appendTo(prodType);
          $('<div class="desc">' + item.prod_type_desc + "</div>").appendTo(
            prodType
          );

          prodType.on("click", handleProductTypeClick);

          itemContainer.append(prodType);
        });
      });
    },
    error: function (xhr, status, error) {
      // Handle any errors that occurred during the request
      console.error(error);
    },
  });
  $("#product-type-close-btn").on("click", function () {
    $("#product-type").hide();
  });
}

SetProduct.prototype.getProdCat = function() {
  function handleProductCatClick() {
    var c0 = $(this).data("data");
    console.log(c0);
  
    $(".prod-cat-input").val(c0.prod_cat_desc);
    $(".prod-cat-id").val(c0.prod_cat_id);
  }

  $.ajax({
    url: "http://localhost:3500/admin/category/list",
    method: "POST",
    dataType: "json",
    data: {
      // Include any necessary data for the request
    },
    success: function (response) {
      // Handle the successful response from the backend
      console.log(response);

      // Show the popup
      $("#product-cat").show();

      // Retrieve and populate the items
      var items = response.recordsets; // Replace with the actual response data structure
      var itemContainer = $("#product-cat-item");
      itemContainer.empty(); // Clear existing items

      // Add items to the container
      items.forEach(function (catArray) {
        catArray.forEach(function (item) {
          var prodCat = $('<div class="product-cat"></div>');

          prodCat.data("data", item);
          $('<div class="desc">' + item.prod_cat_desc + "</div>").appendTo(
            prodCat
          );
          
          prodCat.on("click", handleProductCatClick)
          itemContainer.append(prodCat);
        });
      });
    },
    error: function (xhr, status, error) {
      // Handle any errors that occurred during the request
      console.error(error);
    },
  });
  $("#product-cat-close-btn").on("click", function () {
    $("#product-cat").hide();
  });
}

SetProduct.prototype.getProdGrp = function() {
  function handleProdGrpClick() {
    var c0 = $(this).data("data");
    console.log(c0);

    $(".prod-group-input").val(c0.prod_group_desc);
    $(".prod-group-id").val(c0.prod_group_id);
  }

  $.ajax({
    url: "http://localhost:3500/admin/group/list",
    method: "POST",
    dataType: "json",
    data: {
      // Include any necessary data for the request
    },
    success: function (response) {
      // Handle the successful response from the backend
      console.log(response);

      // Show the popup
      $("#product-group").show();

      // Retrieve and populate the items
      var items = response.recordsets; // Replace with the actual response data structure
      var itemContainer = $("#product-group-item");
      itemContainer.empty();
      // Add items to the container
      items.forEach(function (groupArray) {
        groupArray.forEach(function (item) {
          var prodGroup = $('<div class="product-group"></div>');

          prodGroup.data("data", item);
          $(
            '<div class="id" style="display:none;">' +
              item.prod_group_id +
              "</div>"
          ).appendTo(prodGroup);
          $('<div class="desc">' + item.prod_group_desc + "</div>").appendTo(
            prodGroup
          );

          prodGroup.on("click", handleProdGrpClick)
          itemContainer.append(prodGroup);
        });
      });
    },
    error: function (xhr, status, error) {
      // Handle any errors that occurred during the request
      console.error(error);
    },
  });
  $("#product-group-close-btn").on("click", function () {
    $("#product-group").hide();
  });
}

SetProduct.prototype.getUom = function() {
  function handleSelectUom() {
    var c0 = $(this).data("data");
    console.log(c0);

    $(".uom-input").val(c0.uom_desc);
    $(".uom-id").val(c0.uom_id);
  }

  $.ajax({
    url: "http://localhost:3500/admin/uom/list",
    method: "POST",
    dataType: "json",
    data: {
      // Include any necessary data for the request
    },
    success: function (response) {
      // Handle the successful response from the backend
      console.log(response);

      // Show the popup
      $("#uom").show();

      // Retrieve and populate the items
      var items = response.recordsets; // Replace with the actual response data structure
      var itemContainer = $("#uom-item");
      itemContainer.empty(); // Clear existing items

      // Add items to the container
      items.forEach(function (uomArray) {
        uomArray.forEach(function (item) {
          var uom = $('<div class="uom"></div>');
          uom.data("data", item);
          // $(
          //   '<div class="id" style="display:none;">' + item.uom_id + "</div>"
          // ).appendTo(uom);
          $('<div class="desc">' + item.uom_desc + "</div>").appendTo(uom);

          uom.on("click", handleSelectUom)
          itemContainer.append(uom);
        });
      });
    },
    error: function (xhr, status, error) {
      // Handle any errors that occurred during the request
      console.error(error);
    },
  });
  $("#uom-close-btn").on("click", function () {
    $("#uom").hide();
  });
}

// Tax 1 = Service Charge
SetProduct.prototype.getServiceCharge = function() {
  function handleSelectSC() {
    var c0 = $(this).data("data");
    console.log(c0);

    $(".tax1-input").val(c0.tax_desc);
    $(".tax1-code").val(c0.tax_code);
  }

  $.ajax({
    url: "http://localhost:3500/admin/tax/list",
    method: "POST",
    dataType: "json",
    data: {
      // Include any necessary data for the request
    },
    success: function (response) {
      // Handle the successful response from the backend
      console.log(response);

      // Show the popup
      $("#tax1").show();

      // Retrieve and populate the items
      var items = response.recordsets; // Replace with the actual response data structure
      var itemContainer = $("#tax1-item");
      itemContainer.empty(); // Clear existing items

      // Add items to the container
      items.forEach(function (taxArray) {
        taxArray.forEach(function (item) {
          var tax1 = $('<div class="tax1"></div>');
          tax1.data("data", item);
          $('<div class="desc">' + item.tax_desc + "</div>").appendTo(tax1);

          tax1.on("click", handleSelectSC)
          itemContainer.append(tax1);
        });
      });
    },
    error: function (xhr, status, error) {
      // Handle any errors that occurred during the request
      console.error(error);
    },
  });
  $("#tax1-close-btn").on("click", function () {
    $("#tax1").hide();
  });
}

// Tax 2 = SST
SetProduct.prototype.getSST = function() {
  function handleSelectSST() {
    var c0 = $(this).data("data");
    console.log(c0);

    $(".tax2-input").val(c0.tax_desc);
    $(".tax2-code").val(c0.tax_code);
  }
  $.ajax({
    url: "http://localhost:3500/admin/tax/list",
    method: "POST",
    dataType: "json",
    data: {
      // Include any necessary data for the request
    },
    success: function (response) {
      // Handle the successful response from the backend
      console.log(response);

      // Show the popup
      $("#tax2").show();

      // Retrieve and populate the items
      var items = response.recordsets; // Replace with the actual response data structure
      var itemContainer = $("#tax2-item");
      itemContainer.empty(); // Clear existing items

      // Add items to the container
      items.forEach(function (taxArray) {
        taxArray.forEach(function (item) {
          var tax2 = $('<div class="tax2"></div>');
          tax2.data("data", item);
          $('<div class="desc">' + item.tax_desc + "</div>").appendTo(tax2);

          tax2.on("click", handleSelectSST)
          itemContainer.append(tax2);
        });
      });
    },
    error: function (xhr, status, error) {
      // Handle any errors that occurred during the request
      console.error(error);
    },
  });
  $("#tax2-close-btn").on("click", function () {
    $("#tax2").hide();
  });
}

SetProduct.prototype.getAddon = function () {
  function updateAddonInput() {
    var selectedAddons = $(".addon.selected");
    var addonInput = $(".addon-input");

    // Clear the addonIds array before updating
    addonIds = [];

    addonInput.empty();

    if (selectedAddons.length > 0) {
      selectedAddons.each(function () {
        var addonData = $(this).data("data");
        addonIds.push(addonData.addon_id);
        $(
          '<div class="selected-addon">' + addonData.addon_code + "</div>"
        ).appendTo(addonInput);
      });
    } else {
      $('<div class="selected-addon">None</div>').appendTo(addonInput);
    }

    console.log(addonIds);
  }
  const self = this
  $.ajax({
    url: "http://localhost:3500/admin/addon/list",
    method: "POST",
    dataType: "JSON",
    data: {},
    success: function (response) {
      console.log(response);

      var items = response.recordsets;
      var itemContainer = $("#addon-item");
      itemContainer.empty();

      items.forEach(function (addonArray) {
        addonArray.forEach(function (item) {
          var addon = $('<div class="addon"></div>');
          addon.data("data", item);
          $('<div class="desc">' + item.addon_code + "</div>").appendTo(addon);

          addon.on("click", function () {
            $(this).toggleClass("selected"); // Toggle the 'selected' class on click
            self.updateAddonInput();
          });

          itemContainer.append(addon);
        });
      });

      $("#addon").show();
    },
    error: function (xhr, status, error) {
      // Handle any errors that occurred during the request
      console.error(error);
    },
  });

  $("#addon-close-btn").on("click", function () {
    $("#addon").hide();
  });
};

// $(document).on("click", ".btn-select-addon", function () {
//   $.ajax({
//     url: "http://localhost:3500/admin/addon/list",
//     method: "POST",
//     dataType: "JSON",
//     data: {},
//     success: function (response) {
//       console.log(response);

//       var items = response.recordsets;
//       var itemContainer = $("#addon-item");
//       itemContainer.empty();

//       items.forEach(function (addonArray) {
//         addonArray.forEach(function (item) {
//           var addon = $('<div class="addon"></div>');
//           addon.data("data", item);
//           // $(
//           //   '<div class="id" style="display:none;">' + item.uom_id + "</div>"
//           // ).appendTo(uom);
//           $('<div class="desc">' + item.addon_code + "</div>").appendTo(addon);

//           addon.on("click", function () {
//             $(this).toggleClass("selected"); // Toggle the 'selected' class on click
//             updateAddonInput();
//           });

//           itemContainer.append(addon);
//         });
//       });

//       $("#addon").show();
//     },
//     error: function (xhr, status, error) {
//       // Handle any errors that occurred during the request
//       console.error(error);
//     },
//   });
//   $("#addon-close-btn").on("click", function () {
//     $("#addon").hide();
//   });
// });

// function updateAddonInput() {
//   var selectedAddons = $(".addon.selected");
//   var addonInput = $(".addon-input");

//   // Clear the addonIds array before updating
//   addonIds = [];

//   addonInput.empty();

//   if (selectedAddons.length > 0) {
//     selectedAddons.each(function () {
//       var addonData = $(this).data("data");
//       addonIds.push(addonData.addon_id);
//       $(
//         '<div class="selected-addon">' + addonData.addon_code + "</div>"
//       ).appendTo(addonInput);
//     });
//   } else {
//     $('<div class="selected-addon">None</div>').appendTo(addonInput);
//   }

//   console.log(addonIds);
// }

SetProduct.prototype.getRequest = function() {
  function updateRequestInput() {
    var selectedRequests = $(".request.selected");
    var requestInput = $(".request-input");
  
    requestCode = [];
    requestInput.empty();
  
    if (selectedRequests.length > 0) {
      selectedRequests.each(function () {
        var requestData = $(this).data("data");
        requestCode.push(requestData.request_group_code);
        $(
          '<div class="selected-request">' +
            requestData.request_group_code +
            "</div>"
        ).appendTo(requestInput);
        console.log(requestData);
        console.log(requestCode);
      });
    } else {
      $('<div class="selected-request">None</div>').appendTo(requestInput);
    }
    console.log(requestCode);
  }

  $.ajax({
    url: "http://localhost:3500/admin/request/request_group",
    method: "POST",
    dataType: "JSON",
    data: {},
    success: function (response) {
      console.log(response);

      var items = response.recordsets;
      var itemContainer = $("#request-item");
      itemContainer.empty();

      items.forEach(function (requestArray) {
        requestArray.forEach(function (item) {
          var request = $('<div class="request"></div>');
          request.data("data", item);
          // $(
          //   '<div class="id" style="display:none;">' + item.uom_id + "</div>"
          // ).appendTo(uom);
          $('<div class="desc">' + item.request_group_code + "</div>").appendTo(
            request
          );

          request.on("click", function () {
            $(this).toggleClass("selected"); // Toggle the 'selected' class on click
            updateRequestInput();
          });

          itemContainer.append(request);
        });
      });

      $("#request").show();
    },
    error: function (xhr, status, error) {
      // Handle any errors that occurred during the request
      console.error(error);
    },
  });
  $("#request-close-btn").on("click", function () {
    $("#request").hide();
  });
}

// $(document).on("click", ".btn-select-request", function () {
//   $.ajax({
//     url: "http://localhost:3500/admin/request/request_group",
//     method: "POST",
//     dataType: "JSON",
//     data: {},
//     success: function (response) {
//       console.log(response);

//       var items = response.recordsets;
//       var itemContainer = $("#request-item");
//       itemContainer.empty();

//       items.forEach(function (requestArray) {
//         requestArray.forEach(function (item) {
//           var request = $('<div class="request"></div>');
//           request.data("data", item);
//           // $(
//           //   '<div class="id" style="display:none;">' + item.uom_id + "</div>"
//           // ).appendTo(uom);
//           $('<div class="desc">' + item.request_group_code + "</div>").appendTo(
//             request
//           );

//           request.on("click", function () {
//             $(this).toggleClass("selected"); // Toggle the 'selected' class on click
//             updateRequestInput();
//           });

//           itemContainer.append(request);
//         });
//       });

//       $("#request").show();
//     },
//     error: function (xhr, status, error) {
//       // Handle any errors that occurred during the request
//       console.error(error);
//     },
//   });
//   $("#request-close-btn").on("click", function () {
//     $("#request").hide();
//   });
// });

// function updateRequestInput() {
//   var selectedRequests = $(".request.selected");
//   var requestInput = $(".request-input");

//   requestCode = [];
//   requestInput.empty();

//   if (selectedRequests.length > 0) {
//     selectedRequests.each(function () {
//       var requestData = $(this).data("data");
//       requestCode.push(requestData.request_group_code);
//       $(
//         '<div class="selected-request">' +
//           requestData.request_group_code +
//           "</div>"
//       ).appendTo(requestInput);
//       console.log(requestData);
//       console.log(requestCode);
//     });
//   } else {
//     $('<div class="selected-request">None</div>').appendTo(requestInput);
//   }
//   console.log(requestCode);
// }

SetProduct.prototype.handleMenuItemSave = function() {
  // Create a FormData object to send the data including the image
  var formData = new FormData();
  var prodId = $(".prod-id-input").val();
  var prodType = $(".prod-type-id").val();
  var prodCat = $(".prod-cat-id").val();
  var prodGroup = $(".prod-group-id").val();
  var prodItemCode = $(".prod-code-input").val();
  var barCode = $(".barcode-input").val();
  var prodDesc = $(".prod-desc-input").val();
  var imgUrl = $(".image").val();
  var isActive = $(".is-active-input").hasClass("btn-checkbox") ? "1" : "0";
  var prodDesc2 = $(".prod-desc2-input").val();
  var uom = $(".uom-id").val();
  var startDt = $(".start-dt-input").val();
  var endDt = $(".end-dt-input").val();
  var prepareTime = $(".prepare-time-input").val();
  // put in request array!!
  var price = $(".price-input").val();
  var cost = $(".cost-input").val();
  var tax1 = $(".tax1-code").val();
  var includeTax1 = $(".include-tax1-input").hasClass("btn-checkbox")
    ? "1"
    : "0";
  var tax2 = $(".tax2-code").val();
  var includeTax2 = $(".include-tax2-input").hasClass("btn-checkbox")
    ? "1"
    : "0";
  var includeTax2 = $(".include-tax2-input").hasClass("btn-checkbox")
    ? "1"
    : "0";
  var calctax2 = $(".calc-after-tax1-input").hasClass("btn-checkbox")
    ? "1"
    : "0";
  console.log(addonIds);
  console.log(requestCode);
  console.log(imgUrl);
  var productData = {
    prodId: prodId !== "" ? prodId : undefined,
    prodType: prodType === "" ? undefined : prodType,
    prodCat: prodCat === "" ? undefined : prodCat,
    prodGroup: prodGroup === "" ? undefined : prodGroup,
    prodItemCode: prodItemCode === "" ? undefined : prodItemCode,
    barCode: barCode === "" ? undefined : barCode,
    prodDesc: prodDesc === "" ? undefined : prodDesc,
    imgUrl: imgUrl === "" ? undefined : imgUrl,
    isActive: isActive,
    prodDesc2: prodDesc2 === "" ? undefined : prodDesc2,
    uom: uom === "" ? undefined : uom,
    startDt: startDt === "" ? undefined : startDt,
    endDt: endDt === "" ? undefined : endDt,
    prepareTime: prepareTime === "" ? undefined : prepareTime,
    addon: addon,
    request: request,
    price: price === "" ? undefined : price,
    cost: cost === "" ? undefined : cost,
    tax1: tax1,
    include_tax1: includeTax1,
    tax2: tax2,
    include_tax2: includeTax2,
    calctax2: calctax2,
  };
  console.log(productData.prodId);
  // Append all the form fields to the FormData object
  formData.append("current_uid", sessionStorage.getItem("a"));
  if (typeof productData.prodId !== "undefined") {
    formData.append("prod_id", productData.prodId);
  }
  formData.append("prod_cat_id", productData.prodCat);
  formData.append("prod_code", productData.prodItemCode);
  formData.append("prod_desc", productData.prodDesc);
  formData.append("barcode", productData.barCode);
  formData.append("price", productData.price);
  if (typeof productData.cost !== "undefined") {
    formData.append("cost", productData.cost);
  }
  formData.append("uom_id", productData.uom);
  formData.append("prod_type_id", productData.prodType);
  formData.append("prod_group_id", productData.prodGroup);
  formData.append("is_in_use", productData.isActive);
  formData.append("tax_code1", productData.tax1);
  formData.append("amt_inclusive_tax1", productData.include_tax1);
  formData.append("tax_code2", productData.tax2);
  formData.append("amt_inclusive_tax2", productData.include_tax2);
  formData.append("calc_tax2_after_add_tax1", productData.calctax2);
  formData.append("start_dt", productData.startDt);
  formData.append("end_dt", productData.endDt);
  if (typeof productData.prepareTime !== "undefined") {
    formData.append("prepare_time", productData.prepareTime);
  }
  if (typeof productData.prodDesc2 !== "undefined") {
    formData.append("prod_desc2", productData.prodDesc2);
  }

  // Append the image file to the FormData object
  formData.append("img_url", $(".image")[0].files[0]);

  // Append the addon_ids and request_group_code as JSON strings
  formData.append("addon_id", JSON.stringify(addonIds));
  formData.append("request_group_code", JSON.stringify(requestCode));

  $.ajax({
    url: "http://localhost:3500/admin/menu_item/save",
    method: "POST",
    dataType: "JSON",
    data: formData, // Send the FormData object
    contentType: false, // Important! Don't set content type
    processData: false, // Important! Don't process the data
    success: function (response) {
      console.log(response);
      $(".prod-id-input").val("");
      $(".prod-type-input").val("");
      $(".prod-type-id").val("");
      $(".prod-cat-id").val("");
      $(".prod-cat-input").val("");
      $(".prod-group-id").val("");
      $(".prod-group-input").val("");
      $(".prod-code-input").val("");
      $(".barcode-input").val("");
      $(".prod-desc-input").val("");
      $(".image").val("");
      $(".is-active-input").removeClass("is-active");
      $(".prod-desc2-input").val("");
      $(".uom-id").val("");
      $(".uom-input").val("");
      $(".start-dt-input").val("");
      $(".end-dt-input").val("");
      $(".prepare-time-input").val("");
      $(".price-input").val("");
      $(".cost-input").val("");
      $(".tax1-code").val("");
      $(".tax1-input").val("");
      $(".tax2-code").val("");
      $(".tax2-input").val("");
      $(".include-tax1-input").removeClass("is-active");
      $(".include-tax2-input").removeClass("is-active");
      $(".calc-after-tax1-input").removeClass("is-active");
      addonIds = [];
      requestCode = [];
      console.log(response.response.data.result);
      // Show Popup
      if (response.response.data.result === "OK") {
        var successMsg = "The record have been saved!!";
        $("#popup-message").text(successMsg);
        $("#popup-container").show();
      } else {
        $("#popup-message").text(response.response.data.result);
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
}

SetProduct.prototype.init = function() {
  const self = this;
  console.log(prodId);
  if (prodId) {
    $.ajax({
      url: "http://localhost:3500/admin/menu_item/list",
      method: "POST",
      dataType: "JSON",
      data : {
        prod_id: prodId,
        axn: "setup"
      }, success : function(response) {
        console.log(response);
        const data = response.recordsets[1][0]
        const req = response.recordsets[3]
        const addon = response.recordsets[4]
        console.log(data);
        console.log(req);
        console.log(addon);
        console.log(data.prod_id);
        $(".prod-id-input").val(handleNullOrUndefined(data.prod_id));
        $(".prod-type-input").val(handleNullOrUndefined(data.prod_type_desc));
        $(".prod-type-id").val(handleNullOrUndefined(data.prod_type_id));
        $(".prod-cat-id").val(handleNullOrUndefined(data.prod_cat_id));
        $(".prod-cat-input").val(handleNullOrUndefined(data.prod_cat_desc));
        $(".prod-group-id").val(handleNullOrUndefined(data.prod_group_id));
        $(".prod-group-input").val(handleNullOrUndefined(data.prod_group_desc));
        $(".prod-code-input").val(handleNullOrUndefined(data.prod_code));
        $(".barcode-input").val(handleNullOrUndefined(data.barcode));
        $(".prod-desc-input").val(handleNullOrUndefined(data.prod_desc));
        $(".image").change(function () {
          const input = this;
          const file = input.files[0];
          console.log(file);
        
          if (file) {
            const reader = new FileReader();
        
            reader.onload = function (e) {
              // Assuming there is an <img> tag with class "preview-image"
              $(".preview-image").attr("src", e.target.result);
            };
        
            reader.readAsDataURL(file);
          }
        })
        if (parseInt(data.is_in_use) === 1) {
          $(".is-active-input").addClass("btn-checkbox");
        } else {
          $(".is-active-input").addClass("btn-checkbox0");
        }
        $(".prod-desc2-input").val(handleNullOrUndefined(data.prod_desc2));
        $(".uom-id").val(handleNullOrUndefined(data.uom_id));
        $(".uom-input").val(handleNullOrUndefined(data.uom_desc));
        $(".start-dt-input").val(handleNullOrUndefined(formatDateTime(data.start_dt)));
        $(".end-dt-input").val(handleNullOrUndefined(formatDateTime(data.end_dt)));
        $(".prepare-time-input").val(handleNullOrUndefined(data.prepare_time));
        $(".price-input").val(handleNullOrUndefined(data.price));
        $(".cost-input").val(handleNullOrUndefined(data.cost));
        $(".tax1-code").val(handleNullOrUndefined(data.tax_code1));
        $(".tax1-input").val(handleNullOrUndefined(data.tax_code1));
        $(".tax2-code").val(handleNullOrUndefined(data.tax_code2));
        $(".tax2-input").val(handleNullOrUndefined(data.tax_code2));
        if (parseInt(data.amt_inclusive_tax1) === 1) {
          $(".include-tax1-input").addClass("btn-checkbox");
        } else {
          $(".include-tax1-input").addClass("btn-checkbox0");
        }
        if (parseInt(data.amt_inclusive_tax2) === 1) {
          $(".include-tax2-input").addClass("btn-checkbox");
        } else {
          $(".include-tax2-input").addClass("btn-checkbox0");
        }
        if (parseInt(data.calc_tax2_after_tax1) === 1) {
          $(".calc-after-tax1-input").addClass("btn-checkbox");
        } else {
          $(".calc-after-tax1-input").addClass("btn-checkbox0");
        }

        // Check if addons are selected
        if (addon.length > 0) {
          addonIds = addon.map(addonItem => addonItem.addon_id);
          const selectedAddons = $(".addon.selected");
          const addonInput = $(".addon-input");
          addonInput.empty();
          if (addonIds.length > 0) {
              addonIds.forEach(function (addonId) {
                console.log(addonId);
                  const matchingAddon = addon.find(addonItem => addonItem.addon_id === addonId);
                  console.log(matchingAddon);
                  if (matchingAddon) {
                      $('<div class="selected-addon">' + matchingAddon.addon_code + "</div>").appendTo(addonInput);
                     
                  }
              });
          } else {
              $('<div class="selected-addon">None</div>').appendTo(addonInput);
          }
        }

        // Check if requests are selected
        if (req.length > 0) {
         requestCode = req.map(reqItem => reqItem.request_group_code);
         const selectedRequests = $(".request.selected");
         const requestInput = $(".request-input");
         requestInput.empty();
         if (requestCode.length > 0) {
             requestCode.forEach(function (reqCode) {
               console.log(reqCode);
                 const matchingReq = req.find(reqItem => reqItem.request_group_code === reqCode);
                 console.log(matchingReq);
                 if (matchingReq) {
                     $('<div class="selected-request">' + matchingReq.request_group_code + "</div>").appendTo(requestInput);
                    
                 }
             });
         } else {
             $('<div class="selected-request">None</div>').appendTo(requestInput);
         }
        }

      }, error: function (xhr, status, error) {
        // Handle any errors that occurred during the request
        console.error(error);
      },
    })
  }
  $(".btn-select-prod-type").on("click", function() {
    self.getProdType()
  })

  $(".btn-select-prod-cat").on("click", function() {
    self.getProdCat()
  })

  $(".btn-select-prod-group").on("click", function() {
    self.getProdGrp()
  })

  $(".btn-select-uom").on("click", function() {
    self.getUom()
  })

  $(".btn-select-tax1").on("click", function() {
    self.getServiceCharge()
  })

  $(".btn-select-tax2").on("click", function() {
    self.getSST()
  })
  
  $(".btn-select-addon").on("click", function() {
    self.getAddon()
  })

  $(".btn-select-request").on("click", function() {
    self.getRequest()
  })

  $(".btn-save").on("click", function() {
    self.handleMenuItemSave()
  })
}

//--------------------------------------//
//        Page Startup Function         //
//--------------------------------------//
$(() => {
  const setProduct = new SetProduct();
  setProduct.init();
});