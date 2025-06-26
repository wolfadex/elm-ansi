import readline from "readline";

export function init() {
    process.stdin.setRawMode(true);
    process.stdin.isRaw;
    process.stdin.resume();
    process.stdin.setEncoding("utf-8");

    return {
        columns: process.stdout.columns,
        rows: process.stdout.rows,
    };
}

export function onRawData(callback) {
    process.stdin.on("data", function (data) {
        callback(data.toString());
    });
}

export function onKeypress(callback) {
    readline.emitKeypressEvents(process.stdin);
    process.stdin.on("keypress", (_, key) => callback(key));
}

export function onResize(callback) {
    process.stdout.on("resize", function () {
        callback({
            columns: process.stdout.columns,
            rows: process.stdout.rows,
        });
    });
}

export function writeToStdout(data) {
    process.stdout.write(data);
}
