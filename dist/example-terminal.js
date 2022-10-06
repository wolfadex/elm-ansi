import * as elmAnsi from "./elm-ansi.js";
import { Elm } from "./example-elm-terminal.js";

let app;

const initialState = elmAnsi.init(function (data) {
  if (data === "\x1B" || data === "\u0003") {
    process.exit(0);
  }

  app.ports.stdin.send(data);
});

app = Elm.TerminalExample.init({
  flags: Date.now(),
});

app.ports.stdout.subscribe(function (data) {
  elmAnsi.writeToStdout(data);
});
