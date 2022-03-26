document.getElementById("app").scrollTop = 0;
var data = localStorage.getItem("data");

var app = Elm.Main.init({
    node: document.getElementById("app"),
    flags: JSON.parse(data),
});

//新窗口打开
app.ports.newWindow.subscribe((msg) => {
    window.open(msg);
});

//存储
app.ports.saveToStorage.subscribe((msg) => {
    localStorage.setItem("data", JSON.stringify(msg));
});

app.ports.send.subscribe((msg) => {
    let data = JSON.parse(msg);
    app.ports.receiver.send(data);
});
