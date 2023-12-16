"use strict";

function SetOrderRecordList() {}

SetOrderRecordList.prototype.init = function () {
  const self = this;
  $.ajax({
    url: "http://localhost:3500/admin/order_record/list",
    method: "POST",
    dataType: "JSON",
    data: {

    },
    success: function (response) {
      console.log(response);
      const data = response.recordsets;
      console.log(data);
      const orderRecordItem = $(".item-line");
      orderRecordItem.empty();
      const cloneOrderRecordItem = $(".item-line0");

      data.forEach(function (itemArray) {
        itemArray.forEach(function (item) {
          const c2 = cloneOrderRecordItem
            .clone()
            .removeClass("item-line0")
            .addClass("item-content")
            .data("data", item);
          console.table(item);

          c2.find(".cust-name").text(item.user_name);
          c2.find(".doc-no").text(item.doc_no);
          c2.find(".amount").text(parseFloat(item.amt).toFixed(2));

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
         

          orderRecordItem.append(c2);
        });
      });
    },
    error: function () {
      console.log("An error has occurred.");
    },
  })
}

//--------------------------------------//
//        Page Startup Function         //
//--------------------------------------//
$(() => {
  const setOrderRecordList = new SetOrderRecordList();
  setOrderRecordList.init();
});