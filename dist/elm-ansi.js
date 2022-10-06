export function init(callback) {
  process.stdin.setRawMode(true);
  process.stdin.resume();
  process.stdin.setEncoding("utf-8");

  process.stdin.on("data", function (data) {
    if (callback) {
      callback(data.toString());
    } else {
      const val = data.toString();
      // Assume the user isn't listening to stdin and
      // let them close the app with Esc of Ctrl+c
      if (val === "\x1B" || val === "\u0003") {
        process.exit(0);
      }
    }
  });

  return {
    colorDepth: process.stdout.getColorDepth(),
    columns: process.stdout.columns,
    rows: process.stdout.rows,
  };
}

export function onResize(callback) {
  process.stdout.on("resize", function () {
    callback({ columns: process.stdout.columns, rows: process.stdout.rows });
  });
}

export function writeToStdout(data) {
  process.stdout.write(data);
}
