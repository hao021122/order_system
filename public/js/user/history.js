"use strict";

function History() {}

function formatDate(date) {
  var date = new Date(date);

  var day = date.getDate().toString().padStart(2, "0");
  var month = (date.getMonth() + 1).toString().padStart(2, "0");
  var year = date.getFullYear();

  var fullDate = day + "/" + month + "/" + year;

  return fullDate
}
// $.ajax({
//   url: "http://localhost:3500/order_history",
//   method: "POST",
//   dataType: "JSON",
//   data: {
//     current_uid: sessionStorage.getItem("a"),
//     axn: "history-list",
//   },
//   success: function (response) {
//     console.log(response);

//     var historyItem = $(".history-content");
//     var content = response.recordsets;

//     historyItem.empty();

//     content.forEach((historyArray) => {
//       historyArray.forEach((history) => {
//         var orderHistory = $('<div class="history-item"></div>');
//         orderHistory.data("data", history);
//         console.log(history);
//         $('<div class="doc_no">' + history.doc_no + "</div>").appendTo(
//           orderHistory
//         );
//         historyItem.append(orderHistory);
//       });
//     });
//   },
//   error: function (xhr, status, error) {
//     // Handle any errors that occurred during the request
//     console.error(error);
//   },
// });

History.prototype.init = function () {
  const self = this;
  $.ajax({
    url: "http://localhost:3500/order_history",
    method: "POST",
    dataType: "JSON",
    data: {
      current_uid: sessionStorage.getItem("a"),
      axn:"history-list",
    }, 
    success: function (response) {
      console.log(response);
      const data = response.recordsets;
      console.log(data);
      const historyItem = $(".order-history");
      historyItem.empty();
      const cloneHistoryItem = $(".order-history0");

      data.forEach(function (itemArray) {
        itemArray.forEach(function (item) {
          const c2 = cloneHistoryItem
            .clone()
            .removeClass("order-history0")
            .addClass("history-content")
            .data("data", item);
          console.table(item);


          c2.find(".date").text(formatDate(item.tr_date));
          c2.find(".doc-no").text(item.doc_no);
          c2.find(".amount").text(parseFloat(item.amt).toFixed(2));
          c2.find(".tax").text(parseFloat(item.total_tax).toFixed(2))

          let statusElement = c2.find(".status")
          if (item.tr_status_desc === 'Draft') {
            statusElement.addClass("draft")
            statusElement.text(item.tr_status_desc);
          } else if (item.tr_status_desc === 'Submited') {
            statusElement.addClass("submit")
            statusElement.text(item.tr_status_desc);
          } else if (item.tr_status_desc === 'Cancel') {
            statusElement.addClass("cancel")
            statusElement.text(item.tr_status_desc);
          }else if (item.tr_status_desc === 'Pending') {
            statusElement.addClass("pending")
            statusElement.text(item.tr_status_desc);
          }else if (item.tr_status_desc === 'Approved') {
            statusElement.addClass("approved")
            statusElement.text(item.tr_status_desc);
          }else if (item.tr_status_desc === 'Rejected') {
            statusElement.addClass("rejected")
            statusElement.text(item.tr_status_desc);
          }else if (item.tr_status_desc === 'Completed') {
            statusElement.addClass("completed")
            statusElement.text(item.tr_status_desc);
          }

          historyItem.append(c2);
        });

        historyItem.on(
          "click",
          ".history-content",
          self.getDetails.bind(self)
        );
      });
    }
  })
}

History.prototype.getDetails = function (e) {
  const item = $(e.currentTarget).closest(".history-content")
  const data = item.data("data")
  console.log(data);
  console.log(1111);
  window.location.href = `http://localhost:3500/order_details/details?id=${data.profiler_trans_id}`;
}

//--------------------------------------//
//        Page Startup Function         //
//--------------------------------------//
$(() => {
  const history = new History();
  history.init();
});
