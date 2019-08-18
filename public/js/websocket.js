var input = document.getElementById("chooseFile");
var output = document.getElementById("output");
var connection = document.getElementById("connection");
console.log(location.host);
var socket = new WebSocket("ws://"+location.host+"/ws");

socket.onopen = function () {
    connection.innerHTML = "Status: Connected\n";
};

socket.onclose = function () {
    connection.innerHTML = "Status: Disconnected\n";
};

socket.onmessage = function (e) {
    output.innerHTML += "Console: " + e.data + "\n";
    output.scrollTop = output.scrollHeight;
};

function send() {
    var file = input.files[0];
    var formData = new FormData();
    formData.append('file', file);

    var xhr = new XMLHttpRequest();
    xhr.open('POST', "/upload", false);
    xhr.send(formData);

    socket.send("Burak");
}

$('#chooseFile').bind('change', function () {
    
    var filename = $("#chooseFile").val();
    if (/^\s*$/.test(filename)) {
        $(".file-upload").removeClass('active');
        $("#noFile").text("No file chosen...");
    }
    else {
        $(".file-upload").addClass('active');
        $("#noFile").text(filename.replace("C:\\fakepath\\", ""));
    }
});