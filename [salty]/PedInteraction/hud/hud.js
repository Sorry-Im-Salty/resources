window.addEventListener('message', function(event) {
    var pedCountText = document.getElementById('pedCount');
    var pedNumberSpan = document.getElementById('pedNumber');

    if (event.data.type === "display") {
        pedCountText.style.display = event.data.display ? 'block' : 'none';
    } else if (event.data.type === "updatePedCount") {
        pedNumberSpan.innerText = event.data.count;
        pedNumberSpan.style.color = event.data.count > 50 ? 'red' : 'green';
    }
});