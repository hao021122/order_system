"use-strict";

function setFoodMenu() {}

const backButton = document.querySelector(".btn-back0");

// Add event listener to the button
backButton.addEventListener("click", function () {
  // Navigate to settings.html
  window.location.href = "/admin/settings";
});

function toggleCheckbox(checkbox) {
  checkbox.classList.toggle("btn-checkbox");
  checkbox.classList.toggle("btn-checkbox0");
}
