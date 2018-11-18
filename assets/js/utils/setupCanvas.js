
// Adds a canvas to the view & removes it if it is already there
export const setupCanvas = (app) => {
  var child = document.getElementsByTagName("canvas")[0];
  if (child) {
    child.parentNode.removeChild(child);
  }
  global.document.body.appendChild(app.view);
}
