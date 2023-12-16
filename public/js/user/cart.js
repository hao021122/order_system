"use-strict"

function SetCart() {
  this.currentAddonAmt = 0;
  this.selectedAddonIds = []
  this.selectedRequestIds = []
}

const backButton = document.querySelector(".btn-back");

// Add event listener to the button
backButton.addEventListener("click", function () {
  // Navigate to settings.html
  window.location.href = "/order";
});

function formatDateTime(dateFormat) {
  var date = new Date(dateFormat);

  var day = date.getDate().toString().padStart(2, "0");
  var month = (date.getMonth() + 1).toString().padStart(2, "0");
  var year = date.getFullYear();

  var hours = date.getHours().toString().padStart(2, "0");
  var minutes = date.getMinutes().toString().padStart(2, "0");
  var seconds = date.getSeconds().toString().padStart(2, "0");

  var fullDate = day + "/" + month + "/" + year;
  var fullTime = hours + ":" + minutes + ":" + seconds;

  return fullDate + " at " + fullTime;
}

SetCart.prototype.init = function() {
  const self = this;
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
  
      $("#doc_no").val(doc_no);
      $("#pt_id").val(pt_id);
  
      $.ajax({
        url: "http://localhost:3500/order/cart_list",
        method: "POST",
        dataType: "JSON",
        data: {
          doc_no: $("#doc_no").val(),
          profiler_trans_id: $("#pt_id").val(),
          axn: "cart-list",
        },
        success: function (response) {
          console.log(response);
          console.log(response.recordsets);

          const data = response.recordsets[0]
          const addon = response.recordsets[1]
          const request = response.recordsets[2]
          const cartItem = $(".cart")
          const cloneCartItem = $(".cart0")
          
          if (data.length > 0) {
            cartItem.empty();
            const referenceNumber = data[0].doc_no
            const date = data[0].created_on;
            $("#reference-number").text(referenceNumber);
            if (date) {
              $("#date").text(`${formatDateTime(date)}`);
            }
           
  
            data.forEach(function (cart) {
                const c2 = cloneCartItem.clone().removeClass("cart0").addClass("cart-item").data("data", cart)
                console.log(cart);
  
                const imagePath = cart.img_url
                // Find the index of '\\images'
                const indexOfImages = imagePath.indexOf('\\images');
  
                // Slice the string from the index of '\\images'
                const slicedPath = imagePath.substring(indexOfImages);
  
                const imgElement = $("<img>").attr("src", slicedPath).addClass("cart-img");
                c2.find(".prod-img").append(imgElement);
                c2.find(".prod-desc").text(cart.prod_desc)
                c2.find(".qty").text(cart.qty)
                c2.find(".price").text(cart.amt)
  
                if (addon.length > 0) {
                  addon.forEach(function(addon) {
                    if (addon.tr_id === cart.tr_id) {
                      console.log(addon);
                      c2.find(".addon").text(`${addon.addon_code} (RM ${addon.amt}) `)
  
                      self.currentAddonAmt += parseFloat(addon.amt);
                      self.selectedAddonIds.push(addon.addon_id);
                    }
                  })
                }
  
                if (request.length > 0) {
                  request.forEach(function(req) {
                    if (req.tr_id === cart.tr_id) {
                      console.log(req);
                      c2.find(".request").text(req.request_code)
  
                      // Update selectedRequestIds
                      self.selectedRequestIds.push(req.request_id);
                    }
                  })
                }
  
                cartItem.append(c2)
            })
          }
  
          // Handle quantity adjustments
          cartItem.on("click", ".increment", function () {
            var qtyInput = $(".qty")
            console.log(qtyInput);
            var currentQty = parseInt(qtyInput.val());
            console.log(currentQty);
            qtyInput.val(currentQty + 1);
            updateAmount(qtyInput);
          });
  
          cartItem.on("click", ".decrement", function () {
            var qtyInput = $(this).siblings(".qty");
            var currentQty = parseInt(qtyInput.val());
            if (currentQty > 1) {
              qtyInput.val(currentQty - 1);
              updateAmount(qtyInput);
            }
          });
  
          function updateAmount(qty) {
            var itemLine = qty.closest(".cart-item");
            console.log(itemLine);
            var item = itemLine.data("data");
            console.log(item);
            var newQty = parseInt(qty.val());
            var newAmt = newQty * parseFloat(item.price); // Calculate new amount
            var newSellPrice = newQty * parseFloat(item.sell_price);
            item.amt = newAmt; // Update the amount in the data object
            item.sell_price = newSellPrice;
            itemLine.find(".amt").text(item.amt); // Update the displayed amount
          }

          cartItem.on("click", ".save-line", self.handleSaveItem.bind(self))
          cartItem.on("click", ".delete-line", self.handleDeleteItem.bind(self))
        },
        error: function (xhr, status, error) {
          console.error(error);
        },
      });

      $(".checkout").on("click", function() {
        self.handleItemCheckout()
      })
    },
    error: function (xhr, status, error) {
      // Handle any errors that occurred during the request
      console.error(error);
    },
  });
}

SetCart.prototype.handleSaveItem = function(e) {
  e.preventDefault()
  var itemLine = $(e.currentTarget).closest(".cart-item");
  console.log(itemLine);
  var c0 = itemLine.data("data");
  console.log(c0);
  var qtyInput = itemLine.find(".qty");
  var newQty = parseInt(qtyInput.val());
  console.log(newQty);
  console.log(c0);

  $.ajax({
    url: "http://localhost:3500/order/add_line",
    method: "POST",
    dataType: "JSON",
    data: {
      current_uid: sessionStorage.getItem("a"),
      tr_date: c0.tr_date,
      tr_type: c0.tr_type,
      doc_no: c0.doc_no,
      profiler_trans_id: c0.profiler_trans_id,
      tr_id: c0.tr_id,
      prod_id: c0.prod_id,
      qty: newQty,
      cost: c0.cost,
      amt: c0.amt,
      sell_price: c0.sell_price,
      addon_amt: this.currentAddonAmt,
      addon_id: JSON.stringify(this.selectedAddonIds),
      request_id: JSON.stringify(this.selectedRequestIds)
    },
    success: function (response) {
      console.log(response);

      if (response.result.output.result === "OK") {
        var successMsg = "Items Has Been Saved!!";
        $("#popup-message").text(successMsg);
        $("#popup-container").show();
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
}

SetCart.prototype.handleDeleteItem = function(e) {
  e.preventDefault();
  var itemLine = $(e.currentTarget).closest(".cart-item");
  var c0 = itemLine.data("data");
  console.log(c0);
  $.ajax({
    url: "http://localhost:3500/order/delete_line",
    method: "POST",
    dataType: "JSON",
    data: {
      current_uid: sessionStorage.getItem("a"),
      profiler_trans_id: $("#pt_id").val(),
      tr_id: c0.tr_id,
    },
    success: function (response) {
      console.log(response);

      if (response.output.result === "OK") {
        var successMsg = "Item Line has been Deleted!!";
        $("#popup-message").text(successMsg);
        $("#popup-container").show();
      } else {
        $("#popup-message").text(response.output.result);
        $("#popup-container").show();
      }
      $("#popup-close-btn").on("click", function () {
        $("#popup-container").hide();
      });

      itemLine.fadeOut(100, () => {
       itemLine.remove();
      });
    },
    error: function (xhr, status, error) {
      console.error(error);
    },
  });
}

SetCart.prototype.handleItemCheckout = function() {
  $.ajax({
    url: "http://localhost:3500/order/save",
    method: "POST",
    dataType: "JSON",
    data: {
      current_uid: sessionStorage.getItem("a"),
      tr_type: "AC",
      profiler_trans_id: $("#pt_id").val(),
      doc_no: $("#doc_no").val(),
    },
    success: function (response) {
      console.log(response);

      if (response.recordsets[1][0].result === "OK") {
        var successMsg = "Item Line has been Saved!!";
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
      console.error(error);
    },
  });
}

//--------------------------------------//
//        Page Startup Function         //
//--------------------------------------//
$(() => {
  const setCart = new SetCart();
  setCart.init();
});
