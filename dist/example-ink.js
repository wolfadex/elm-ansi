import * as elmAnsi from "./elm-ansi.js";
import { Elm } from "./example-elm-ink.js";

let app;

const initialState = elmAnsi.init(function (data) {
  if (data === "\x1B" || data === "\u0003") {
    process.exit(0);
  }

  app.ports.stdin.send(data);
});

elmAnsi.onResize(function (colsAndRos) {
  app.ports.resize.send(colsAndRos);
});

app = Elm.InkExample.init({
  flags: initialState,
});

app.ports.stdout.subscribe(function (data) {
  elmAnsi.writeToStdout(data);
});
