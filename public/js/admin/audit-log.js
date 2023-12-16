"use-strict";

function auditLog() {}

auditLog.init = () => {
  $.ajax({
    url: "http://localhost:3500/admin/audit_log/list",
    method: "POST",
    dataType: "JSON",
    data: {
      maximumRows: 100,
    },
    success: function (response) {
      console.log(response);

      var itemList = $(".log-item");
      var content = response.recordsets;
      itemList.empty();

      content.forEach((e) => {
        e.forEach((item) => {
          var logs = $('<div class="audit-log"></div>');

          logs.data("data", item);
          console.log(item);

          $(
            '<div class="w1 center-all module">' + item.module_id + "</div>"
          ).appendTo(logs);
          $(
            '<div class="w2 center-all modified_on">' +
              item.modified_on +
              "</div>"
          ).appendTo(logs);
          $(
            '<div class="w1 center-all modified_by">' +
              item.modified_by +
              "</div>"
          ).appendTo(logs);
          $('<div class="w3 task">' + item.task + "</div>").appendTo(logs);
          itemList.append(logs);
        });
      });
    },
    error: function (xhr, status, error) {
      // Handle any errors that occurred during the request
      console.error(error);
    },
  });
};

$(function () {
  auditLog.init();
});
