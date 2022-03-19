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

//下载备份
/* app.ports.export.subscribe(async (msg) => {
  let myDate = new Date();
  let date_title = `${myDate.getFullYear()}${myDate.getMonth()}${myDate.getDate()}_${myDate.getHours()}${myDate.getMinutes()}${myDate.getSeconds()}`;
  const blob = new Blob([JSON.stringify(msg)], { type: "text/plain" });
  const a = document.createElement("a");
  a.href = URL.createObjectURL(blob);
  document.body.appendChild(a);
  a.download = `lunastart_${date_title}.json`;
  a.click();
  URL.revokeObjectURL(a.href);
  a.remove();
}); */
