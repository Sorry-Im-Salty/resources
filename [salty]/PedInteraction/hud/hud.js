window.addEventListener('message', function(event) {
    if (event.data.type === "updatePedCount") {
        var pedNumberSpan = document.getElementById('pedNumber');
        pedNumberSpan.innerText = event.data.count;

        if (event.data.count > 50) {
            pedNumberSpan.style.color = 'red';
        } else {
            pedNumberSpan.style.color = 'green';
        }
    } else if (event.data.type === "display") {
        var pedCountText = document.getElementById('pedCount');
        
        if (event.data.display) {
            pedCountText.style.display = 'block';
        } else {
            pedCountText.style.display = 'none';
        }
    }
});