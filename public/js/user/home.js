"use-strict"

function UserHome(){
  this.currentAddonAmt = 0;
  this.selectedAddonIds = []
  this.selectedRequestIds = []
}

UserHome.prototype.init = function() {
  const self = this;
  $.ajax({
    url: "http://localhost:3500/order/get_doc_no_pt_id",
    method: "POST",
    dataType: "JSON",
    data: {
      current_uid: sessionStorage.getItem("a"),
      co_id: "8FDF41BB-0285-462E-8FD6-E5D4EB64A808",
    },
    success: function (response) {
      console.log(response);
      console.log(response.output);

      var doc_no = response.output.doc_no;
      var pt_id = response.output.profiler_trans_id;
      console.log(doc_no);

      if (doc_no !== null && doc_no.trim() !== "") {
        $("#doc_no").val(doc_no);
      } else {
        return $("#doc_no").val(undefined);
      }

      if (pt_id !== null && pt_id.trim() !== "") {
        $("#pt_id").val(pt_id);
      } else {
        return $("#pt_id").val("00000000-0000-0000-0000-000000000000");
      }
    },
    error: function (xhr, status, error) {
      // Handle any errors that occurred during the request
      console.error(error);
    },
  });
  self.prodCatList()
  self.menuItemList()

  $(".box-card").on("click", ".addon-item", function (e) {
    self.handleSelectAddon(e);
  });

  $(".box-card").on("click", ".request-item", function (e) {
    self.handleSelectRequest(e);
  });

  $(".box-card").on("click", ".add-cart", function (e) {
    self.addCart(e);
});
}

// List down All Categories
UserHome.prototype.prodCatList = function() {
  const self = this
  $.ajax({
    url: "http://localhost:3500/order/cat_list",
    method: "POST",
    dataType: "JSON",
    data: {
      axn: null,
    },
    success: function (response) {
      console.log(response);
  
      const data = response.recordsets;
      const categoriesItem = $(".categories-container");
      categoriesItem.empty();
      const cloneCategoriesItem = $(".categories-container0");
  
      data.forEach(function (categoryArray) {
        categoryArray.forEach(function (category) {
          const c2 = cloneCategoriesItem
          .clone()
          .removeClass("categories-container0")
          .addClass("categories")
          .data("data", category);
          console.table(category);

          c2.find(".category").text(category.prod_cat_desc)

          categoriesItem.append(c2);

          c2.on("click", function () {
            if ($(this).hasClass("selected")) {
              $(this).removeClass("selected");
              self.menuItemList(undefined);
            } else {
              $(".categories.selected").removeClass("selected");
                  $(this).addClass("selected");
                  self.menuItemList(category.prod_cat_id);
            }
            
          });
        });
      });
    },
    error: function (xhr, status, error) {
      // Handle any errors that occurred during the request
      console.error(error);
    },
  });
}

UserHome.prototype.menuItemList = function(selectedCategory) {
  const self = this;
  // if (selectedCategory === null) {
  //   const selectedCategory = null
  // }
  $.ajax({
    url: "http://localhost:3500/order/menu_list",
    method: "POST",
    dataType: "JSON",
    data: { 
      prod_cat_id: selectedCategory,
      axn: "setup" 
    },
    success: function (response) {
      console.log(response);
      const data = response.recordsets;
      const menuItem = $(".box-card");
      const cloneMenuItem = $(".box-card0")
      
        for (var i = 1; i < data.length; i++) {
          var content = data[i];
          menuItem.empty();
    
          content.forEach(function (menu) {
            const c2 = cloneMenuItem
              .clone()
              .removeClass("box-card0")
              .addClass("card")
              .data("data", menu);
              console.table(menu);

            const imagePath = menu.img_url
            // Find the index of '\\images'
            const indexOfImages = imagePath.indexOf('\\images');
            
            // Slice the string from the index of '\\images'
            const slicedPath = imagePath.substring(indexOfImages);
  
            const imgElement = $("<img>").attr("src", slicedPath);
            c2.find(".img-box").append(imgElement);
            c2.find(".prod-desc").text(menu.prod_desc)
            c2.find(".prod-desc2").text(menu.prod_desc2)
            c2.find(".amt").text(`RM ${parseFloat(menu.price).toFixed(2)}`);
  
            // Quantity adjustment buttons
            const qtyAdjustment = $('<div class="flex-row center-all qty-adjustment"></div>');
            qtyAdjustment.append('<div class="btn-sm decrement">&#45;</div>');
            qtyAdjustment.append('<input type="text" class="qty-input">');
            qtyAdjustment.append('<div class="btn-sm increment">&#43;</div>');
            c2.find(".sel-qty").append(qtyAdjustment);

            // Add to Cart button
            const addToCartBtn = $(
              '<a class="add-cart">' +
                '<span class="material-icons">' +
                'add_shopping_cart' +
                '</span>' +
                'Add To Cart' +
                '</a>'
            );
            c2.find(".action").append(addToCartBtn);
            menuItem.append(c2);

            self.getAddon(menu.prod_id, c2)
            self.getRequest(menu.prod_id, c2)
          })

         

          // Handle quantity adjustments
          menuItem.on("click", ".increment", function () {
            var qtyInput = $(this).closest(".card").find(".qty-input");
            console.log(qtyInput);
            var currentQty = parseInt(qtyInput.val()) || 0; // If NaN, set to 0
            console.log(currentQty);
            qtyInput.val(currentQty + 1);
          });

          menuItem.on("click", ".decrement", function () {
            var qtyInput = $(this).closest(".card").find(".qty-input");
            console.log(qtyInput);
            var currentQty = parseInt(qtyInput.val()) || 0; // If NaN, set to 0
            console.log(currentQty);
            if (currentQty > 1) {
                qtyInput.val(currentQty - 1);
            }
          });         
          
           // Set initial value to 1 for all quantity inputs
           $(".qty-input").val(1)
        }
      
  
      // // Handle quantity adjustments
      // menuItem.on("click", ".increment", function () {
      //   var qtyInput = $(this).closest(".card").find(".qty-input");
      //   console.log(qtyInput);
      //   var currentQty = parseInt(qtyInput.val());
      //   console.log(currentQty);
      //   qtyInput.val(currentQty + 1);
      // });
  
      // menuItem.on("click", ".decrement", function () {
      //   var qtyInput = $(this).siblings(".qty-input");
      //   var currentQty = parseInt(qtyInput.val());
      //   if (currentQty > 1) {
      //     qtyInput.val(currentQty - 1);
      //   }
      // });
      // Handle quantity adjustments
      // Set initial value to 1
      // $(".qty-input").val(1);

      // menuItem.on("click", ".increment", function () {
      //   var qtyInput = $(this).closest(".card").find(".qty-input");
      //   console.log(qtyInput);
      //   var currentQty = parseInt(qtyInput.val()) || 0; // If NaN, set to 0
      //   console.log(currentQty);
      //   qtyInput.val(currentQty + 1);
      // });

      // menuItem.on("click", ".decrement", function () {
      //   var qtyInput = $(this).closest(".card").find(".qty-input");
      //   console.log(qtyInput);
      //   var currentQty = parseInt(qtyInput.val()) || 0; // If NaN, set to 0
      //   console.log(currentQty);
      //   if (currentQty > 1) {
      //     qtyInput.val(currentQty - 1);
      //   }
// });
    },
    error: function (xhr, status, error) {
      // Handle any errors that occurred during the request
      console.error(error);
    },
  });
}

UserHome.prototype.getAddon = function(prod_id, menuItemElement) {
  $.ajax({
    url: "http://localhost:3500/order/menu_list",
    method: "POST",
    dataType: "JSON",
    data: { 
      prod_id: prod_id,
      axn: "addon"
    },
    success: function (response) {
      console.log(response);
      // Implement logic to display addons in menuItemElement
      const prodIdData = response.recordsets[1][0].prod_id
      const data = response.recordsets[2]
      console.log(data);
      
      // Implement logic to display requests in menuItemElement
      // Check the prod_id
      if (prod_id === prodIdData) {
        data.forEach(function (addon){
          const addonItem = $(`<div class="addon-item">${addon.addon_code} (RM ${addon.addon_amt})</div>`);
          
          // Set data attribute with addon details
          addonItem.data("data", addon);
          
          menuItemElement.append(addonItem);
        })  
      }
    },
    error: function (xhr, status, error) {
      // Handle any errors that occurred during the request
      console.error(error);
    },
  });
}

UserHome.prototype.handleSelectAddon = function(e) {
  const self = this;
  const addonItem = $(e.currentTarget);
  const c0 = addonItem.data("data")
  console.log(c0);

  // Toggle the "selected" class
  addonItem.toggleClass("selected");

  // Check if the addon is selected and update the array accordingly
  if (addonItem.hasClass("selected")) {
    // Add the selected addon ID to the array
    this.selectedAddonIds.push(c0.addon_id);
  } else {
    // Remove the addon ID from the array if deselected
    const index = this.selectedAddonIds.indexOf(c0.addon_id);
    if (index !== -1) {
      this.selectedAddonIds.splice(index, 1);
    }
  }

  // Log the selected addon IDs
  console.log("Selected Addon IDs:", this.selectedAddonIds);

  // Calculate and log the total addon amount
  const selectedAddons = $(".addon-item.selected");
  this.currentAddonAmt = 0;

  selectedAddons.each((index, element) => {
    const addon = $(element).data("data");
    this.currentAddonAmt += parseFloat(addon.addon_amt);
  });

  console.log("Total Addon Amount:", this.currentAddonAmt);
}

UserHome.prototype.getRequest = function(prod_id, menuItemElement) {
  $.ajax({
    url: "http://localhost:3500/order/menu_list",
    method: "POST",
    dataType: "JSON",
    data: { 
      prod_id: prod_id,
      axn: "req"
    },
    success: function (response) {
      // Process and display requests
      console.log(response);
      const prodIdData = response.recordsets[1][0].prod_id
      const data = response.recordsets[2]

      // Implement logic to display requests in menuItemElement
      // Check the prod_id
      if (prod_id === prodIdData) {
        data.forEach(function (req){
          const requestItem = $(`<div class="request-item">${req.request_code}</div>`);
      
          // Set data attribute with addon details
          requestItem.data("data", req);
          
          menuItemElement.append(requestItem);
        })
      }
    },
    error: function (xhr, status, error) {
      // Handle any errors that occurred during the request
      console.error(error);
    },
  });
}

UserHome.prototype.handleSelectRequest = function(e) {
  const self = this;
  const requestItem = $(e.currentTarget)
  const c0 = requestItem.data("data")
  console.log(c0);

  // Toggle the "selected" class
 requestItem.toggleClass("selected");

 // Check if the request is selected and update the array accordingly
 if (requestItem.hasClass("selected")) {
   // Add the selected addon ID to the array
   this.selectedRequestIds.push(c0.request_id);
 } else {
   // Remove the request ID from the array if deselected
   const index = this.selectedRequestIds.indexOf(c0.request_id);
   if (index !== -1) {
     this.selectedRequestIds.splice(index, 1);
   }
 }

 // Log the selected request IDs
 console.log("Selected Request IDs:", this.selectedRequestIds);
}

UserHome.prototype.addCart = function(e) {
  const self = this;
  var c0 = $(e.currentTarget).closest(".card").data("data");
  console.log(111);
  console.log(c0);
  
  var doc_no = $("#doc_no").val();
  var pt_id = $("#pt_id").val();
  var emptyDocNo = doc_no !== "" ? doc_no : undefined;
  var emptyPtId = pt_id !== "" ? pt_id : undefined;

  $.ajax({
    url: "http://localhost:3500/order/add_line",
    method: "POST",
    dataType: "JSON",
    data: {
      current_uid: sessionStorage.getItem("a"),
      doc_group: "receipt_no",
      doc_no: emptyDocNo,
      profiler_trans_id: emptyPtId,
      tr_id: undefined,
      prod_id: c0.prod_id,
      qty: $(".qty-input").val(),
      cost: c0.cost,
      amt: c0.price,
      sell_price: c0.gross_amt,
      addon_amt: this.currentAddonAmt,
      addon_id: JSON.stringify(this.selectedAddonIds),
      request_id: JSON.stringify(this.selectedRequestIds)
    },
    success: function (response) {
      console.log(response);

      if (response.result.output.result === "OK") {
        var successMsg = `Item Has Been Saved in ${doc_no}`;
        $("#popup-message").text(successMsg);
        $("#popup-container").show();
        performSecondAjaxRequest();

        // Clear selectedAddonIds and selectedRequestIds arrays
        self.selectedAddonIds = [];
        self.selectedRequestIds = [];
      } else {
        $("#popup-message").text(response.result.output.result);
        $("#popup-container").show();
      }
      $("#popup-close-btn").on("click", function () {
        $("#popup-container").hide();
      });
    },
    error: function (error) {
      console.error(error);
    },
  });

  function performSecondAjaxRequest() {
    $.ajax({
      url: "http://localhost:3500/order/get_doc_no_pt_id",
      method: "POST",
      dataType: "JSON",
      data: {
        current_uid: sessionStorage.getItem("a"),
      },
      success: function (response) {
        console.log(response);
        console.log(response.output);

        var doc_no = response.output.doc_no;
        var pt_id = response.output.profiler_trans_id;
        console.log(doc_no);
        if (doc_no !== null && doc_no.trim() !== "") {
          $("#doc_no").val(doc_no);
        } else {
          return $("#doc_no").val(undefined);
        }

        if (pt_id !== null && pt_id.trim() !== "") {
          $("#pt_id").val(pt_id);
        } else {
          return $("#pt_id").val("00000000-0000-0000-0000-000000000000");
        }
      },
      error: function (xhr, status, error) {
        // Handle any errors that occurred during the request
        console.error(error);
      },
    });
  }
}

//--------------------------------------//
//        Page Startup Function         //
//--------------------------------------//
$(() => {
  const userHome = new UserHome();
  userHome.init();
});