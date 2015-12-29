window.__electron__ipc = require("electron").ipcRenderer;
window.__resemble = require("resemblejs");

function dataURItoBlob(dataURI) {
  // convert base64 to raw binary data held in a string
  var byteString = atob(dataURI.split(',')[1]);

  // separate out the mime component
  var mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0];

  // write the bytes of the string to an ArrayBuffer
  var arrayBuffer = new ArrayBuffer(byteString.length);
  var _ia = new Uint8Array(arrayBuffer);
  for (var i = 0; i < byteString.length; i++) {
      _ia[i] = byteString.charCodeAt(i);
  }

  var dataView = new DataView(arrayBuffer);
  var blob = new Blob([dataView], { type: mimeString });
  return blob;
}

__electron__ipc.on("compare", function(event, dataURI1, dataURI2){
  var image1 = dataURItoBlob(dataURI1);
  var image2 = dataURItoBlob(dataURI2);

  try {
    __resemble(image1)
    .compareTo(image2)
    .ignoreColors()
    .ignoreAntialiasing()
    .onComplete(function(data){
      __electron__ipc.send("compare-results", data, data.getImageDataUrl());
    });
  }
  catch (e) {
    __electron__ipc.send("compare-error", e.message);
  }
});

__electron__ipc.on("exec-js", function(event, functionString){
  try {
    eval("window.__electron__ipc_exec_js = " + functionString);

    ret = __electron__ipc_exec_js();

    requestAnimationFrame(function(){
      event.sender.send("exec-js-success", ret);
    });
  }
  catch (e) {
    event.sender.send("exec-js-error", e.message);
  }
});