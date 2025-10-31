importScripts("sql-wasm.js");
importScripts("sqflite_sw.dart.js");

// Support older without serviceWorker API
self.addEventListener("message", async function (e) {
  try {
    await handleMessage(e.data.id, e.data.request);
  } catch (error) {
    console.error(error);
  }
});
