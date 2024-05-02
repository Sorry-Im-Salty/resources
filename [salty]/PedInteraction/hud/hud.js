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

window.addEventListener('message', function(event) {
    var handOfGodStatus = document.getElementById('handOfGodStatus');
    
    if (event.data.type === "toggleHandOfGod") {
        handOfGodStatus.innerText = event.data.isActive ? 'Hand of God Enabled' : 'Hand of God Disabled';
        handOfGodStatus.style.display = 'block';

        if (!event.data.isActive) {
            setTimeout(function() {
                handOfGodStatus.style.opacity = '0';
                setTimeout(function() {
                    handOfGodStatus.style.display = 'none';
                    handOfGodStatus.style.opacity = '1';
                }, 1000);
            }, 2000);
        }
    }
});