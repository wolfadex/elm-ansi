# elm-ansi

An Elm (plus JS) package for writing apps for your terminal.

## Getting Started

- Make sure you have both Nix and direnv installed
- Clone this repo, or use the GitHub `Use this template` button
- Inside your cloned repo, run `direnv allow`
- Run `npm install && npm run dev` to generate your compiled Elm
- Run `node dist/example.js` to view the demo
- Alter `src/Main.elm` to try out different things


## Thoughts

This should be split into 3 packages
- `elm-ansi`: a package for working with ansi and basic String related things. E.g. width of a String in terminal columns. Kind of like `elm/virtual-dom` meets `elm/code`.
- `elm-terminal`: a higher level package for working with the terminal. E.g. `Terminal.bold "some words"` instead of `Ansi.bold ++ "some words ++ Ansi.unbold`. Think of this like `elm/html`.
- `elm-ink`: a fairly high level package for building cli apps. E.g. `Ink.column [ Ink.bold, Ink.color Ink.red ] [ Ink.text "some text" ]`. Think of this like `mdgriffith/elm-ui`.