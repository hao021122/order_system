// Client-side JavaScript
setInterval(function() {
    // Make an AJAX request to the server to indicate user activity
    // Use fetch or any other AJAX library
    fetch('/keep-alive', { method: 'POST' })
        .then(response => response.json())
        .then(data => console.log(data))
        .catch(error => console.error('Error:', error));
}, 3 * 60 * 1000); // 3 minutes
