import * as elmAnsi from "./elm-ansi.js";
import { Elm } from "./example-elm-ansi.js";

let app;

elmAnsi.init();
elmAnsi.onRawData(function (data) {
  app.ports.stdin.send(data);
});

app = Elm.AnsiExample.init();

app.ports.stdout.subscribe(function (data) {
  elmAnsi.writeToStdout(data);
});

app.ports.exit.subscribe(function (code) {
  process.exit(code);
});
