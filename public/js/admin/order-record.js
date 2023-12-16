"use-strict"

function SetOrderRecord() {}

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

SetOrderRecord.prototype.init = function () {
  const self = this;
    $.ajax({
        url: "http://localhost:3500/admin/order_record/list",
        method: "POST",
        dataType: "JSON",
        data: {

        }, success: function (response) {
            console.log(response);
            const data = response.recordsets;
            console.log(data);
            const orderRecordItem = $(".order-history");
            orderRecordItem.empty();
            const cloneOrderRecordItem = $(".order-history0");
      
            data.forEach(function (itemArray) {
              itemArray.forEach(function (item) {
                const c2 = cloneOrderRecordItem
                  .clone()
                  .removeClass("order-history0")
                  .addClass("order-content")
                  .data("data", item);
                console.table(item);
      
                c2.find(".created-by").text(item.user_name);
                c2.find(".doc-no").text(item.doc_no);
                c2.find(".amount").text('RM ' + parseFloat(item.amt).toFixed(2));
      
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

                c2.find(".created-on").text(formatDateTime(item.created_on))
               
      
                orderRecordItem.append(c2);
              });

              orderRecordItem.on(
                "click",
                ".order-content",
                self.getDetails.bind(self)
              );
            });
        }
    })
}

SetOrderRecord.prototype.getDetails = function (e) {
  const item = $(e.currentTarget).closest(".order-content")
  const data = item.data("data")
  console.log(data);
  window.location.href = `http://localhost:3500/admin/order_details/details?id=${data.profiler_trans_id}`;
}

//--------------------------------------//
//        Page Startup Function         //
//--------------------------------------//
$(() => {
    const setOrderRecord = new SetOrderRecord();
    setOrderRecord.init();
  });