window.addEventListener('message', function(event) {
    var data = event.data;
    let date = new Date();
    let day = String(date.getDate()).padStart(2, '0');
    let month = String(date.getMonth() + 1).padStart(2, '0');
    let year = date.getFullYear();
    let hours = String(date.getHours()).padStart(2, '0');
    let minutes = String(date.getMinutes()).padStart(2, '0');
    let seconds = String(date.getSeconds()).padStart(2, '0');
    let currentTime = hours + ':' + minutes;
    let currentDate = day + '/' + month + '/' + year + ' ' + currentTime;

    if (data.type === 'gmtTogglePauseMenu') {
        if (data.toggle === true) {
            document.getElementById('gmtRoot').style.display = "block";
            document.getElementById('todaysDate').innerText = currentDate;
            document.getElementById('gmtDLastName').innerText = data.gmtDLastName;
            document.getElementById('gmtDBirthdate').innerText = data.gmtDBirthdate;
            document.getElementById('gmtDGender').innerText = data.gmtDGender;
            document.getElementById('gmtPlrName').innerText = data.gmtPlrName;
            document.getElementById('totalPlayers').innerText = data.totalPlayers;
        }  else if (data.toggle === false) {
            document.getElementById('gmtRoot').style.display = "none";
        }
    }
});

var elements = document.querySelectorAll("#gmtCuBbox, #gmtconnect, #gmtPmRow, #gmtPmBox3, #gmtPmBox2, #gmtCsettings, #gmtCsButtons, #gmtComRules, #Store, #joinDiscord, #disupte, #gmtCdisconnect, #gmtCmap, .gmtPmNavCont, .gmtNavRow, .gmtPmBox2, .gmtPmBox3");

elements.forEach(function(element) {
    element.addEventListener('mouseenter', function() {
        var audio = new Audio('hover.mp3');
        audio.volume = 0.3;
        audio.play();
    });
});

$('#gmtCsettings').click(function(){
    $.post('https://gmt/Settings', JSON.stringify({}), function(data) {
    });
});

$('#Store').click(function(){
    $.post('https://gmt/Store', JSON.stringify({}), function(data) {
    });
});

$('#gmtCuBbox').click(function(){
    $.post('https://gmt/Guide', JSON.stringify({}), function(data) {
    });
});

$('#twitter').click(function(){
    $.post('https://gmt/Twitter', JSON.stringify({}), function(data) {
    });
});

$('#dispute').click(function(){
    $.post('https://gmt/Dispute', JSON.stringify({}), function(data) {
    });
});

$('#gmtconnect').click(function(){
    $.post('https://gmt/DeathMatchF8', JSON.stringify({}), function(data) {
    });
});

$('#joinDiscord').click(function(){
    $.post('https://gmt/DeathMatchDiscord', JSON.stringify({}), function(data) {
    });
});

$('#website').click(function(){
    $.post('https://gmt/Website', JSON.stringify({}), function(data) {
    });
});

$('#gmtCuBbox').click(function(){
    $.post('https://gmt/Guide', JSON.stringify({}), function(data) {
    });
});

$('#gmtPmBox3').click(function(){
    $.post('https://gmt/ComRules', JSON.stringify({}), function(data) {
    });
});

$('#gmtPmBox2').click(function(){
    $.post('https://gmt/Rules', JSON.stringify({}), function(data) {
    });
});
$('#gmtCmap').click(function(){
    $.post('https://gmt/Map', JSON.stringify({}), function(data) {
    });
});
$('#gmtCdisconnect').click(function(){
    $.post('https://gmt/Disconnect', JSON.stringify({}), function(data) {
    });
});

window.addEventListener('keydown', function(event) {
    if (event.key === "Escape") {
        $.post('https://gmt/Close', JSON.stringify({}), function(data) {});
        document.getElementById('gmtRoot').style.display = "none";
    }
});