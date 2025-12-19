module Ansi.String exposing
    ( width
    , padRight
    , strip
    , regex
    , emojiRegex
    )

{-| Various functions for working with ANSI strings. E.g. when measuring the width of an ANSI string you don't want to include any of the command characters, only those that are displayed in the terminal.

@docs width
@docs padRight
@docs strip

@docs regex
@docs emojiRegex

-}

import Ansi.Internal exposing (EastAsianCharWidth(..))
import Regex exposing (Regex)


{-| Add the specified string to the right side of your `String` so that it's the specified length. If this is impossible, e.g. in `padRight 10 "🌈" "hello"` the 🌈 is 2 columns wide meaning that your result will be either 9 or 11 columns wide, then white space will be added to fill the remaining space.
-}
padRight : Int -> String -> String -> String
padRight desiredWidth paddingStr content =
    let
        currentWidth : Int
        currentWidth =
            width content

        paddingWidth : Int
        paddingWidth =
            width paddingStr

        padAmount : Int
        padAmount =
            (desiredWidth - currentWidth) // paddingWidth

        whiteSpaceAmount : Int
        whiteSpaceAmount =
            desiredWidth - (paddingWidth * padAmount) - currentWidth
    in
    content ++ String.repeat padAmount paddingStr ++ String.repeat whiteSpaceAmount " "


{-| Measures the width of a `String` in terminal columns.

Copied from <https://github.com/sindresorhus/string-width/blob/main/index.js>

-}
width : String -> Int
width str =
    if String.isEmpty str then
        0

    else
        let
            withoutAnsi : String
            withoutAnsi =
                strip str
        in
        if String.isEmpty withoutAnsi then
            0

        else
            let
                replacedEmojis : String
                replacedEmojis =
                    Regex.replace emojiRegex (\_ -> "  ") withoutAnsi
            in
            String.foldl
                (\char total ->
                    let
                        codePoint : Int
                        codePoint =
                            Char.toCode char
                    in
                    if
                        (codePoint <= 0x1F)
                            || (codePoint >= 0x7F && codePoint <= 0x9F)
                            || (codePoint >= 0x0300 && codePoint <= 0x036F)
                    then
                        total

                    else
                        case Ansi.Internal.eastAsianWidth (String.fromChar char) of
                            Just FullWidth ->
                                total + 2

                            Just Wide ->
                                total + 2

                            Just Ambiguous ->
                                total + 1

                            Nothing ->
                                total

                            _ ->
                                total + 1
                )
                0
                replacedEmojis


{-| Remove ANSI characters from a `String`. Mostly useful for things like measuring a `String`'s width.
-}
strip : String -> String
strip =
    Regex.replace regex (\_ -> "")


{-| Matches ANSI characters

Borrowed from <https://github.com/chalk/ansi-regex>

-}
regex : Regex
regex =
    [ "[\u{001B}\u{009B}][[\\]()#;?]*(?:(?:(?:(?:;[-a-zA-Z\\d\\/#&.:=?%@~_]+)*|[a-zA-Z\\d]+(?:;[-a-zA-Z\\d\\/#&.:=?%@~_]*)*)?\u{0007})"
    , "(?:(?:\\d{1,4}(?:;\\d{0,4})*)?[\\dA-PR-TZcf-nq-uy=><~]))"
    ]
        |> String.join "|"
        |> Regex.fromString
        |> Maybe.withDefault Regex.never


{-| Matches emojis

Borrowed from <https://github.com/mathiasbynens/emoji-regex>

With the removal of:
©®‼⁉™ℹ↔-↙↩↪⌨⏏⏭-⏯⏱⏲⏸-⏺Ⓜ▪▫▶◀◻◼◾☀-☄☎☑☘☠☢☣☦☪☮☯☸-☺♀♂-♟♠♣♥♦♨♻♾⚒⚔-⚗⚙⚛⚜⚠⚧⚰⚱⛈⛏⛑⛩⛰-⛷⛸✂✉✏✒✔✖✝✡✳✴❄❇❣➡

-}
emojiRegex : Regex
emojiRegex =
    "[#*0-9]️?⃣|[⌚⌛♈♓⚽⚾⛄⛵☔☕✈❗❣➡⤴⤵⬅-⬇⬛⬜⭕⚪♿⛺〰〽㊗㊙]️?|[☝✌✍](?:\u{D83C}[\u{DFFB}-\u{DFFF}]|️)?|[✊✋](?:\u{D83C}[\u{DFFB}-\u{DFFF}])?|[⏩-⏬⏰⏳◽⚓⚡⚫⛅⛎⛔⛪⛽✅✨❌❎❓-❕➕-➗➰➿⭐]|⛓️?(?:\u{200D}\u{D83D}\u{DCA5})?|⛹(?:\u{D83C}[\u{DFFB}-\u{DFFF}]|️)?(?:\u{200D}[♀♂]️?)?|❤️?(?:\u{200D}(?:\u{D83D}\u{DD25}|\u{D83E}\u{DE79}))?|\u{D83C}(?:[\u{DC04}\u{DD70}\u{DD71}\u{DD7E}\u{DD7F}\u{DE02}\u{DE37}\u{DF21}\u{DF24}-\u{DF2C}\u{DF36}\u{DF7D}\u{DF96}\u{DF97}\u{DF99}-\u{DF9B}\u{DF9E}\u{DF9F}\u{DFCD}\u{DFCE}\u{DFD4}-\u{DFDF}\u{DFF5}\u{DFF7}]️?|[\u{DF85}\u{DFC2}\u{DFC7}](?:\u{D83C}[\u{DFFB}-\u{DFFF}])?|[\u{DFC4}\u{DFCA}](?:\u{D83C}[\u{DFFB}-\u{DFFF}])?(?:\u{200D}[♀♂]️?)?|[\u{DFCB}\u{DFCC}](?:\u{D83C}[\u{DFFB}-\u{DFFF}]|️)?(?:\u{200D}[♀♂]️?)?|[\u{DCCF}\u{DD8E}\u{DD91}-\u{DD9A}\u{DE01}\u{DE1A}\u{DE2F}\u{DE32}-\u{DE36}\u{DE38}-\u{DE3A}\u{DE50}\u{DE51}\u{DF00}-\u{DF20}\u{DF2D}-\u{DF35}\u{DF37}-\u{DF43}\u{DF45}-\u{DF4A}\u{DF4C}-\u{DF7C}\u{DF7E}-\u{DF84}\u{DF86}-\u{DF93}\u{DFA0}-\u{DFC1}\u{DFC5}\u{DFC6}\u{DFC8}\u{DFC9}\u{DFCF}-\u{DFD3}\u{DFE0}-\u{DFF0}\u{DFF8}-\u{DFFF}]|\u{DDE6}\u{D83C}[\u{DDE8}-\u{DDEC}\u{DDEE}\u{DDF1}\u{DDF2}\u{DDF4}\u{DDF6}-\u{DDFA}\u{DDFC}\u{DDFD}\u{DDFF}]|\u{DDE7}\u{D83C}[\u{DDE6}\u{DDE7}\u{DDE9}-\u{DDEF}\u{DDF1}-\u{DDF4}\u{DDF6}-\u{DDF9}\u{DDFB}\u{DDFC}\u{DDFE}\u{DDFF}]|\u{DDE8}\u{D83C}[\u{DDE6}\u{DDE8}\u{DDE9}\u{DDEB}-\u{DDEE}\u{DDF0}-\u{DDF7}\u{DDFA}-\u{DDFF}]|\u{DDE9}\u{D83C}[\u{DDEA}\u{DDEC}\u{DDEF}\u{DDF0}\u{DDF2}\u{DDF4}\u{DDFF}]|\u{DDEA}\u{D83C}[\u{DDE6}\u{DDE8}\u{DDEA}\u{DDEC}\u{DDED}\u{DDF7}-\u{DDFA}]|\u{DDEB}\u{D83C}[\u{DDEE}-\u{DDF0}\u{DDF2}\u{DDF4}\u{DDF7}]|\u{DDEC}\u{D83C}[\u{DDE6}\u{DDE7}\u{DDE9}-\u{DDEE}\u{DDF1}-\u{DDF3}\u{DDF5}-\u{DDFA}\u{DDFC}\u{DDFE}]|\u{DDED}\u{D83C}[\u{DDF0}\u{DDF2}\u{DDF3}\u{DDF7}\u{DDF9}\u{DDFA}]|\u{DDEE}\u{D83C}[\u{DDE8}-\u{DDEA}\u{DDF1}-\u{DDF4}\u{DDF6}-\u{DDF9}]|\u{DDEF}\u{D83C}[\u{DDEA}\u{DDF2}\u{DDF4}\u{DDF5}]|\u{DDF0}\u{D83C}[\u{DDEA}\u{DDEC}-\u{DDEE}\u{DDF2}\u{DDF3}\u{DDF5}\u{DDF7}\u{DDFC}\u{DDFE}\u{DDFF}]|\u{DDF1}\u{D83C}[\u{DDE6}-\u{DDE8}\u{DDEE}\u{DDF0}\u{DDF7}-\u{DDFB}\u{DDFE}]|\u{DDF2}\u{D83C}[\u{DDE6}\u{DDE8}-\u{DDED}\u{DDF0}-\u{DDFF}]|\u{DDF3}\u{D83C}[\u{DDE6}\u{DDE8}\u{DDEA}-\u{DDEC}\u{DDEE}\u{DDF1}\u{DDF4}\u{DDF5}\u{DDF7}\u{DDFA}\u{DDFF}]|\u{DDF4}\u{D83C}\u{DDF2}|\u{DDF5}\u{D83C}[\u{DDE6}\u{DDEA}-\u{DDED}\u{DDF0}-\u{DDF3}\u{DDF7}-\u{DDF9}\u{DDFC}\u{DDFE}]|\u{DDF6}\u{D83C}\u{DDE6}|\u{DDF7}\u{D83C}[\u{DDEA}\u{DDF4}\u{DDF8}\u{DDFA}\u{DDFC}]|\u{DDF8}\u{D83C}[\u{DDE6}-\u{DDEA}\u{DDEC}-\u{DDF4}\u{DDF7}-\u{DDF9}\u{DDFB}\u{DDFD}-\u{DDFF}]|\u{DDF9}\u{D83C}[\u{DDE6}\u{DDE8}\u{DDE9}\u{DDEB}-\u{DDED}\u{DDEF}-\u{DDF4}\u{DDF7}\u{DDF9}\u{DDFB}\u{DDFC}\u{DDFF}]|\u{DDFA}\u{D83C}[\u{DDE6}\u{DDEC}\u{DDF2}\u{DDF3}\u{DDF8}\u{DDFE}\u{DDFF}]|\u{DDFB}\u{D83C}[\u{DDE6}\u{DDE8}\u{DDEA}\u{DDEC}\u{DDEE}\u{DDF3}\u{DDFA}]|\u{DDFC}\u{D83C}[\u{DDEB}\u{DDF8}]|\u{DDFD}\u{D83C}\u{DDF0}|\u{DDFE}\u{D83C}[\u{DDEA}\u{DDF9}]|\u{DDFF}\u{D83C}[\u{DDE6}\u{DDF2}\u{DDFC}]|\u{DF44}(?:\u{200D}\u{D83D}\u{DFEB})?|\u{DF4B}(?:\u{200D}\u{D83D}\u{DFE9})?|\u{DFC3}(?:\u{D83C}[\u{DFFB}-\u{DFFF}])?(?:\u{200D}(?:[♀♂]️?(?:\u{200D}➡️?)?|➡️?))?|\u{DFF3}️?(?:\u{200D}(?:⚧️?|\u{D83C}\u{DF08}))?|\u{DFF4}(?:\u{200D}☠️?|\u{DB40}\u{DC67}\u{DB40}\u{DC62}\u{DB40}(?:\u{DC65}\u{DB40}\u{DC6E}\u{DB40}\u{DC67}|\u{DC73}\u{DB40}\u{DC63}\u{DB40}\u{DC74}|\u{DC77}\u{DB40}\u{DC6C}\u{DB40}\u{DC73})\u{DB40}\u{DC7F})?)|\u{D83D}(?:[\u{DC3F}\u{DCFD}\u{DD49}\u{DD4A}\u{DD6F}\u{DD70}\u{DD73}\u{DD76}-\u{DD79}\u{DD87}\u{DD8A}-\u{DD8D}\u{DDA5}\u{DDA8}\u{DDB1}\u{DDB2}\u{DDBC}\u{DDC2}-\u{DDC4}\u{DDD1}-\u{DDD3}\u{DDDC}-\u{DDDE}\u{DDE1}\u{DDE3}\u{DDE8}\u{DDEF}\u{DDF3}\u{DDFA}\u{DECB}\u{DECD}-\u{DECF}\u{DEE0}-\u{DEE5}\u{DEE9}\u{DEF0}\u{DEF3}]️?|[\u{DC42}\u{DC43}\u{DC46}-\u{DC50}\u{DC66}\u{DC67}\u{DC6B}-\u{DC6D}\u{DC72}\u{DC74}-\u{DC76}\u{DC78}\u{DC7C}\u{DC83}\u{DC85}\u{DC8F}\u{DC91}\u{DCAA}\u{DD7A}\u{DD95}\u{DD96}\u{DE4C}\u{DE4F}\u{DEC0}\u{DECC}](?:\u{D83C}[\u{DFFB}-\u{DFFF}])?|[\u{DC6E}-\u{DC71}\u{DC73}\u{DC77}\u{DC81}\u{DC82}\u{DC86}\u{DC87}\u{DE45}-\u{DE47}\u{DE4B}\u{DE4D}\u{DE4E}\u{DEA3}\u{DEB4}\u{DEB5}](?:\u{D83C}[\u{DFFB}-\u{DFFF}])?(?:\u{200D}[♀♂]️?)?|[\u{DD74}\u{DD90}](?:\u{D83C}[\u{DFFB}-\u{DFFF}]|️)?|[\u{DC00}-\u{DC07}\u{DC09}-\u{DC14}\u{DC16}-\u{DC25}\u{DC27}-\u{DC3A}\u{DC3C}-\u{DC3E}\u{DC40}\u{DC44}\u{DC45}\u{DC51}-\u{DC65}\u{DC6A}\u{DC79}-\u{DC7B}\u{DC7D}-\u{DC80}\u{DC84}\u{DC88}-\u{DC8E}\u{DC90}\u{DC92}-\u{DCA9}\u{DCAB}-\u{DCFC}\u{DCFF}-\u{DD3D}\u{DD4B}-\u{DD4E}\u{DD50}-\u{DD67}\u{DDA4}\u{DDFB}-\u{DE2D}\u{DE2F}-\u{DE34}\u{DE37}-\u{DE41}\u{DE43}\u{DE44}\u{DE48}-\u{DE4A}\u{DE80}-\u{DEA2}\u{DEA4}-\u{DEB3}\u{DEB7}-\u{DEBF}\u{DEC1}-\u{DEC5}\u{DED0}-\u{DED2}\u{DED5}-\u{DED8}\u{DEDC}-\u{DEDF}\u{DEEB}\u{DEEC}\u{DEF4}-\u{DEFC}\u{DFE0}-\u{DFEB}\u{DFF0}]|\u{DC08}(?:\u{200D}⬛)?|\u{DC15}(?:\u{200D}\u{D83E}\u{DDBA})?|\u{DC26}(?:\u{200D}(?:⬛|\u{D83D}\u{DD25}))?|\u{DC3B}(?:\u{200D}❄️?)?|\u{DC41}️?(?:\u{200D}\u{D83D}\u{DDE8}️?)?|\u{DC68}(?:\u{200D}(?:[⚕⚖✈]️?|❤️?\u{200D}\u{D83D}(?:\u{DC8B}\u{200D}\u{D83D})?\u{DC68}|\u{D83C}[\u{DF3E}\u{DF73}\u{DF7C}\u{DF93}\u{DFA4}\u{DFA8}\u{DFEB}\u{DFED}]|\u{D83D}(?:[\u{DC68}\u{DC69}]\u{200D}\u{D83D}(?:\u{DC66}(?:\u{200D}\u{D83D}\u{DC66})?|\u{DC67}(?:\u{200D}\u{D83D}[\u{DC66}\u{DC67}])?)|[\u{DCBB}\u{DCBC}\u{DD27}\u{DD2C}\u{DE80}\u{DE92}]|\u{DC66}(?:\u{200D}\u{D83D}\u{DC66})?|\u{DC67}(?:\u{200D}\u{D83D}[\u{DC66}\u{DC67}])?)|\u{D83E}(?:[\u{DDAF}\u{DDBC}\u{DDBD}](?:\u{200D}➡️?)?|[\u{DDB0}-\u{DDB3}]))|\u{D83C}(?:\u{DFFB}(?:\u{200D}(?:[⚕⚖✈]️?|❤️?\u{200D}\u{D83D}(?:\u{DC8B}\u{200D}\u{D83D})?\u{DC68}\u{D83C}[\u{DFFB}-\u{DFFF}]|\u{D83C}[\u{DF3E}\u{DF73}\u{DF7C}\u{DF93}\u{DFA4}\u{DFA8}\u{DFEB}\u{DFED}]|\u{D83D}(?:[\u{DCBB}\u{DCBC}\u{DD27}\u{DD2C}\u{DE80}\u{DE92}]|\u{DC30}\u{200D}\u{D83D}\u{DC68}\u{D83C}[\u{DFFC}-\u{DFFF}])|\u{D83E}(?:[\u{DD1D}\u{DEEF}]\u{200D}\u{D83D}\u{DC68}\u{D83C}[\u{DFFC}-\u{DFFF}]|[\u{DDAF}\u{DDBC}\u{DDBD}](?:\u{200D}➡️?)?|[\u{DDB0}-\u{DDB3}])))?|\u{DFFC}(?:\u{200D}(?:[⚕⚖✈]️?|❤️?\u{200D}\u{D83D}(?:\u{DC8B}\u{200D}\u{D83D})?\u{DC68}\u{D83C}[\u{DFFB}-\u{DFFF}]|\u{D83C}[\u{DF3E}\u{DF73}\u{DF7C}\u{DF93}\u{DFA4}\u{DFA8}\u{DFEB}\u{DFED}]|\u{D83D}(?:[\u{DCBB}\u{DCBC}\u{DD27}\u{DD2C}\u{DE80}\u{DE92}]|\u{DC30}\u{200D}\u{D83D}\u{DC68}\u{D83C}[\u{DFFB}\u{DFFD}-\u{DFFF}])|\u{D83E}(?:[\u{DD1D}\u{DEEF}]\u{200D}\u{D83D}\u{DC68}\u{D83C}[\u{DFFB}\u{DFFD}-\u{DFFF}]|[\u{DDAF}\u{DDBC}\u{DDBD}](?:\u{200D}➡️?)?|[\u{DDB0}-\u{DDB3}])))?|\u{DFFD}(?:\u{200D}(?:[⚕⚖✈]️?|❤️?\u{200D}\u{D83D}(?:\u{DC8B}\u{200D}\u{D83D})?\u{DC68}\u{D83C}[\u{DFFB}-\u{DFFF}]|\u{D83C}[\u{DF3E}\u{DF73}\u{DF7C}\u{DF93}\u{DFA4}\u{DFA8}\u{DFEB}\u{DFED}]|\u{D83D}(?:[\u{DCBB}\u{DCBC}\u{DD27}\u{DD2C}\u{DE80}\u{DE92}]|\u{DC30}\u{200D}\u{D83D}\u{DC68}\u{D83C}[\u{DFFB}\u{DFFC}\u{DFFE}\u{DFFF}])|\u{D83E}(?:[\u{DD1D}\u{DEEF}]\u{200D}\u{D83D}\u{DC68}\u{D83C}[\u{DFFB}\u{DFFC}\u{DFFE}\u{DFFF}]|[\u{DDAF}\u{DDBC}\u{DDBD}](?:\u{200D}➡️?)?|[\u{DDB0}-\u{DDB3}])))?|\u{DFFE}(?:\u{200D}(?:[⚕⚖✈]️?|❤️?\u{200D}\u{D83D}(?:\u{DC8B}\u{200D}\u{D83D})?\u{DC68}\u{D83C}[\u{DFFB}-\u{DFFF}]|\u{D83C}[\u{DF3E}\u{DF73}\u{DF7C}\u{DF93}\u{DFA4}\u{DFA8}\u{DFEB}\u{DFED}]|\u{D83D}(?:[\u{DCBB}\u{DCBC}\u{DD27}\u{DD2C}\u{DE80}\u{DE92}]|\u{DC30}\u{200D}\u{D83D}\u{DC68}\u{D83C}[\u{DFFB}-\u{DFFD}\u{DFFF}])|\u{D83E}(?:[\u{DD1D}\u{DEEF}]\u{200D}\u{D83D}\u{DC68}\u{D83C}[\u{DFFB}-\u{DFFD}\u{DFFF}]|[\u{DDAF}\u{DDBC}\u{DDBD}](?:\u{200D}➡️?)?|[\u{DDB0}-\u{DDB3}])))?|\u{DFFF}(?:\u{200D}(?:[⚕⚖✈]️?|❤️?\u{200D}\u{D83D}(?:\u{DC8B}\u{200D}\u{D83D})?\u{DC68}\u{D83C}[\u{DFFB}-\u{DFFF}]|\u{D83C}[\u{DF3E}\u{DF73}\u{DF7C}\u{DF93}\u{DFA4}\u{DFA8}\u{DFEB}\u{DFED}]|\u{D83D}(?:[\u{DCBB}\u{DCBC}\u{DD27}\u{DD2C}\u{DE80}\u{DE92}]|\u{DC30}\u{200D}\u{D83D}\u{DC68}\u{D83C}[\u{DFFB}-\u{DFFE}])|\u{D83E}(?:[\u{DD1D}\u{DEEF}]\u{200D}\u{D83D}\u{DC68}\u{D83C}[\u{DFFB}-\u{DFFE}]|[\u{DDAF}\u{DDBC}\u{DDBD}](?:\u{200D}➡️?)?|[\u{DDB0}-\u{DDB3}])))?))?|\u{DC69}(?:\u{200D}(?:[⚕⚖✈]️?|❤️?\u{200D}\u{D83D}(?:\u{DC8B}\u{200D}\u{D83D})?[\u{DC68}\u{DC69}]|\u{D83C}[\u{DF3E}\u{DF73}\u{DF7C}\u{DF93}\u{DFA4}\u{DFA8}\u{DFEB}\u{DFED}]|\u{D83D}(?:[\u{DCBB}\u{DCBC}\u{DD27}\u{DD2C}\u{DE80}\u{DE92}]|\u{DC66}(?:\u{200D}\u{D83D}\u{DC66})?|\u{DC67}(?:\u{200D}\u{D83D}[\u{DC66}\u{DC67}])?|\u{DC69}\u{200D}\u{D83D}(?:\u{DC66}(?:\u{200D}\u{D83D}\u{DC66})?|\u{DC67}(?:\u{200D}\u{D83D}[\u{DC66}\u{DC67}])?))|\u{D83E}(?:[\u{DDAF}\u{DDBC}\u{DDBD}](?:\u{200D}➡️?)?|[\u{DDB0}-\u{DDB3}]))|\u{D83C}(?:\u{DFFB}(?:\u{200D}(?:[⚕⚖✈]️?|❤️?\u{200D}\u{D83D}(?:[\u{DC68}\u{DC69}]|\u{DC8B}\u{200D}\u{D83D}[\u{DC68}\u{DC69}])\u{D83C}[\u{DFFB}-\u{DFFF}]|\u{D83C}[\u{DF3E}\u{DF73}\u{DF7C}\u{DF93}\u{DFA4}\u{DFA8}\u{DFEB}\u{DFED}]|\u{D83D}(?:[\u{DCBB}\u{DCBC}\u{DD27}\u{DD2C}\u{DE80}\u{DE92}]|\u{DC30}\u{200D}\u{D83D}\u{DC69}\u{D83C}[\u{DFFC}-\u{DFFF}])|\u{D83E}(?:[\u{DDAF}\u{DDBC}\u{DDBD}](?:\u{200D}➡️?)?|[\u{DDB0}-\u{DDB3}]|\u{DD1D}\u{200D}\u{D83D}[\u{DC68}\u{DC69}]\u{D83C}[\u{DFFC}-\u{DFFF}]|\u{DEEF}\u{200D}\u{D83D}\u{DC69}\u{D83C}[\u{DFFC}-\u{DFFF}])))?|\u{DFFC}(?:\u{200D}(?:[⚕⚖✈]️?|❤️?\u{200D}\u{D83D}(?:[\u{DC68}\u{DC69}]|\u{DC8B}\u{200D}\u{D83D}[\u{DC68}\u{DC69}])\u{D83C}[\u{DFFB}-\u{DFFF}]|\u{D83C}[\u{DF3E}\u{DF73}\u{DF7C}\u{DF93}\u{DFA4}\u{DFA8}\u{DFEB}\u{DFED}]|\u{D83D}(?:[\u{DCBB}\u{DCBC}\u{DD27}\u{DD2C}\u{DE80}\u{DE92}]|\u{DC30}\u{200D}\u{D83D}\u{DC69}\u{D83C}[\u{DFFB}\u{DFFD}-\u{DFFF}])|\u{D83E}(?:[\u{DDAF}\u{DDBC}\u{DDBD}](?:\u{200D}➡️?)?|[\u{DDB0}-\u{DDB3}]|\u{DD1D}\u{200D}\u{D83D}[\u{DC68}\u{DC69}]\u{D83C}[\u{DFFB}\u{DFFD}-\u{DFFF}]|\u{DEEF}\u{200D}\u{D83D}\u{DC69}\u{D83C}[\u{DFFB}\u{DFFD}-\u{DFFF}])))?|\u{DFFD}(?:\u{200D}(?:[⚕⚖✈]️?|❤️?\u{200D}\u{D83D}(?:[\u{DC68}\u{DC69}]|\u{DC8B}\u{200D}\u{D83D}[\u{DC68}\u{DC69}])\u{D83C}[\u{DFFB}-\u{DFFF}]|\u{D83C}[\u{DF3E}\u{DF73}\u{DF7C}\u{DF93}\u{DFA4}\u{DFA8}\u{DFEB}\u{DFED}]|\u{D83D}(?:[\u{DCBB}\u{DCBC}\u{DD27}\u{DD2C}\u{DE80}\u{DE92}]|\u{DC30}\u{200D}\u{D83D}\u{DC69}\u{D83C}[\u{DFFB}\u{DFFC}\u{DFFE}\u{DFFF}])|\u{D83E}(?:[\u{DDAF}\u{DDBC}\u{DDBD}](?:\u{200D}➡️?)?|[\u{DDB0}-\u{DDB3}]|\u{DD1D}\u{200D}\u{D83D}[\u{DC68}\u{DC69}]\u{D83C}[\u{DFFB}\u{DFFC}\u{DFFE}\u{DFFF}]|\u{DEEF}\u{200D}\u{D83D}\u{DC69}\u{D83C}[\u{DFFB}\u{DFFC}\u{DFFE}\u{DFFF}])))?|\u{DFFE}(?:\u{200D}(?:[⚕⚖✈]️?|❤️?\u{200D}\u{D83D}(?:[\u{DC68}\u{DC69}]|\u{DC8B}\u{200D}\u{D83D}[\u{DC68}\u{DC69}])\u{D83C}[\u{DFFB}-\u{DFFF}]|\u{D83C}[\u{DF3E}\u{DF73}\u{DF7C}\u{DF93}\u{DFA4}\u{DFA8}\u{DFEB}\u{DFED}]|\u{D83D}(?:[\u{DCBB}\u{DCBC}\u{DD27}\u{DD2C}\u{DE80}\u{DE92}]|\u{DC30}\u{200D}\u{D83D}\u{DC69}\u{D83C}[\u{DFFB}-\u{DFFD}\u{DFFF}])|\u{D83E}(?:[\u{DDAF}\u{DDBC}\u{DDBD}](?:\u{200D}➡️?)?|[\u{DDB0}-\u{DDB3}]|\u{DD1D}\u{200D}\u{D83D}[\u{DC68}\u{DC69}]\u{D83C}[\u{DFFB}-\u{DFFD}\u{DFFF}]|\u{DEEF}\u{200D}\u{D83D}\u{DC69}\u{D83C}[\u{DFFB}-\u{DFFD}\u{DFFF}])))?|\u{DFFF}(?:\u{200D}(?:[⚕⚖✈]️?|❤️?\u{200D}\u{D83D}(?:[\u{DC68}\u{DC69}]|\u{DC8B}\u{200D}\u{D83D}[\u{DC68}\u{DC69}])\u{D83C}[\u{DFFB}-\u{DFFF}]|\u{D83C}[\u{DF3E}\u{DF73}\u{DF7C}\u{DF93}\u{DFA4}\u{DFA8}\u{DFEB}\u{DFED}]|\u{D83D}(?:[\u{DCBB}\u{DCBC}\u{DD27}\u{DD2C}\u{DE80}\u{DE92}]|\u{DC30}\u{200D}\u{D83D}\u{DC69}\u{D83C}[\u{DFFB}-\u{DFFE}])|\u{D83E}(?:[\u{DDAF}\u{DDBC}\u{DDBD}](?:\u{200D}➡️?)?|[\u{DDB0}-\u{DDB3}]|\u{DD1D}\u{200D}\u{D83D}[\u{DC68}\u{DC69}]\u{D83C}[\u{DFFB}-\u{DFFE}]|\u{DEEF}\u{200D}\u{D83D}\u{DC69}\u{D83C}[\u{DFFB}-\u{DFFE}])))?))?|\u{DD75}(?:\u{D83C}[\u{DFFB}-\u{DFFF}]|️)?(?:\u{200D}[♀♂]️?)?|\u{DE2E}(?:\u{200D}\u{D83D}\u{DCA8})?|\u{DE35}(?:\u{200D}\u{D83D}\u{DCAB})?|\u{DE36}(?:\u{200D}\u{D83C}\u{DF2B}️?)?|\u{DE42}(?:\u{200D}[↔↕]️?)?|\u{DEB6}(?:\u{D83C}[\u{DFFB}-\u{DFFF}])?(?:\u{200D}(?:[♀♂]️?(?:\u{200D}➡️?)?|➡️?))?)|\u{D83E}(?:[\u{DD0C}\u{DD0F}\u{DD18}-\u{DD1F}\u{DD30}-\u{DD34}\u{DD36}\u{DD77}\u{DDB5}\u{DDB6}\u{DDBB}\u{DDD2}\u{DDD3}\u{DDD5}\u{DEC3}-\u{DEC5}\u{DEF0}\u{DEF2}-\u{DEF8}](?:\u{D83C}[\u{DFFB}-\u{DFFF}])?|[\u{DD26}\u{DD35}\u{DD37}-\u{DD39}\u{DD3C}-\u{DD3E}\u{DDB8}\u{DDB9}\u{DDCD}\u{DDCF}\u{DDD4}\u{DDD6}-\u{DDDD}](?:\u{D83C}[\u{DFFB}-\u{DFFF}])?(?:\u{200D}[♀♂]️?)?|[\u{DDDE}\u{DDDF}](?:\u{200D}[♀♂]️?)?|[\u{DD0D}\u{DD0E}\u{DD10}-\u{DD17}\u{DD20}-\u{DD25}\u{DD27}-\u{DD2F}\u{DD3A}\u{DD3F}-\u{DD45}\u{DD47}-\u{DD76}\u{DD78}-\u{DDB4}\u{DDB7}\u{DDBA}\u{DDBC}-\u{DDCC}\u{DDD0}\u{DDE0}-\u{DDFF}\u{DE70}-\u{DE7C}\u{DE80}-\u{DE8A}\u{DE8E}-\u{DEC2}\u{DEC6}\u{DEC8}\u{DECD}-\u{DEDC}\u{DEDF}-\u{DEEA}\u{DEEF}]|\u{DDCE}(?:\u{D83C}[\u{DFFB}-\u{DFFF}])?(?:\u{200D}(?:[♀♂]️?(?:\u{200D}➡️?)?|➡️?))?|\u{DDD1}(?:\u{200D}(?:[⚕⚖✈]️?|\u{D83C}[\u{DF3E}\u{DF73}\u{DF7C}\u{DF84}\u{DF93}\u{DFA4}\u{DFA8}\u{DFEB}\u{DFED}]|\u{D83D}[\u{DCBB}\u{DCBC}\u{DD27}\u{DD2C}\u{DE80}\u{DE92}]|\u{D83E}(?:[\u{DDAF}\u{DDBC}\u{DDBD}](?:\u{200D}➡️?)?|[\u{DDB0}-\u{DDB3}\u{DE70}]|\u{DD1D}\u{200D}\u{D83E}\u{DDD1}|\u{DDD1}\u{200D}\u{D83E}\u{DDD2}(?:\u{200D}\u{D83E}\u{DDD2})?|\u{DDD2}(?:\u{200D}\u{D83E}\u{DDD2})?))|\u{D83C}(?:\u{DFFB}(?:\u{200D}(?:[⚕⚖✈]️?|❤️?\u{200D}(?:\u{D83D}\u{DC8B}\u{200D})?\u{D83E}\u{DDD1}\u{D83C}[\u{DFFC}-\u{DFFF}]|\u{D83C}[\u{DF3E}\u{DF73}\u{DF7C}\u{DF84}\u{DF93}\u{DFA4}\u{DFA8}\u{DFEB}\u{DFED}]|\u{D83D}(?:[\u{DCBB}\u{DCBC}\u{DD27}\u{DD2C}\u{DE80}\u{DE92}]|\u{DC30}\u{200D}\u{D83E}\u{DDD1}\u{D83C}[\u{DFFC}-\u{DFFF}])|\u{D83E}(?:[\u{DDAF}\u{DDBC}\u{DDBD}](?:\u{200D}➡️?)?|[\u{DDB0}-\u{DDB3}\u{DE70}]|\u{DD1D}\u{200D}\u{D83E}\u{DDD1}\u{D83C}[\u{DFFB}-\u{DFFF}]|\u{DEEF}\u{200D}\u{D83E}\u{DDD1}\u{D83C}[\u{DFFC}-\u{DFFF}])))?|\u{DFFC}(?:\u{200D}(?:[⚕⚖✈]️?|❤️?\u{200D}(?:\u{D83D}\u{DC8B}\u{200D})?\u{D83E}\u{DDD1}\u{D83C}[\u{DFFB}\u{DFFD}-\u{DFFF}]|\u{D83C}[\u{DF3E}\u{DF73}\u{DF7C}\u{DF84}\u{DF93}\u{DFA4}\u{DFA8}\u{DFEB}\u{DFED}]|\u{D83D}(?:[\u{DCBB}\u{DCBC}\u{DD27}\u{DD2C}\u{DE80}\u{DE92}]|\u{DC30}\u{200D}\u{D83E}\u{DDD1}\u{D83C}[\u{DFFB}\u{DFFD}-\u{DFFF}])|\u{D83E}(?:[\u{DDAF}\u{DDBC}\u{DDBD}](?:\u{200D}➡️?)?|[\u{DDB0}-\u{DDB3}\u{DE70}]|\u{DD1D}\u{200D}\u{D83E}\u{DDD1}\u{D83C}[\u{DFFB}-\u{DFFF}]|\u{DEEF}\u{200D}\u{D83E}\u{DDD1}\u{D83C}[\u{DFFB}\u{DFFD}-\u{DFFF}])))?|\u{DFFD}(?:\u{200D}(?:[⚕⚖✈]️?|❤️?\u{200D}(?:\u{D83D}\u{DC8B}\u{200D})?\u{D83E}\u{DDD1}\u{D83C}[\u{DFFB}\u{DFFC}\u{DFFE}\u{DFFF}]|\u{D83C}[\u{DF3E}\u{DF73}\u{DF7C}\u{DF84}\u{DF93}\u{DFA4}\u{DFA8}\u{DFEB}\u{DFED}]|\u{D83D}(?:[\u{DCBB}\u{DCBC}\u{DD27}\u{DD2C}\u{DE80}\u{DE92}]|\u{DC30}\u{200D}\u{D83E}\u{DDD1}\u{D83C}[\u{DFFB}\u{DFFC}\u{DFFE}\u{DFFF}])|\u{D83E}(?:[\u{DDAF}\u{DDBC}\u{DDBD}](?:\u{200D}➡️?)?|[\u{DDB0}-\u{DDB3}\u{DE70}]|\u{DD1D}\u{200D}\u{D83E}\u{DDD1}\u{D83C}[\u{DFFB}-\u{DFFF}]|\u{DEEF}\u{200D}\u{D83E}\u{DDD1}\u{D83C}[\u{DFFB}\u{DFFC}\u{DFFE}\u{DFFF}])))?|\u{DFFE}(?:\u{200D}(?:[⚕⚖✈]️?|❤️?\u{200D}(?:\u{D83D}\u{DC8B}\u{200D})?\u{D83E}\u{DDD1}\u{D83C}[\u{DFFB}-\u{DFFD}\u{DFFF}]|\u{D83C}[\u{DF3E}\u{DF73}\u{DF7C}\u{DF84}\u{DF93}\u{DFA4}\u{DFA8}\u{DFEB}\u{DFED}]|\u{D83D}(?:[\u{DCBB}\u{DCBC}\u{DD27}\u{DD2C}\u{DE80}\u{DE92}]|\u{DC30}\u{200D}\u{D83E}\u{DDD1}\u{D83C}[\u{DFFB}-\u{DFFD}\u{DFFF}])|\u{D83E}(?:[\u{DDAF}\u{DDBC}\u{DDBD}](?:\u{200D}➡️?)?|[\u{DDB0}-\u{DDB3}\u{DE70}]|\u{DD1D}\u{200D}\u{D83E}\u{DDD1}\u{D83C}[\u{DFFB}-\u{DFFF}]|\u{DEEF}\u{200D}\u{D83E}\u{DDD1}\u{D83C}[\u{DFFB}-\u{DFFD}\u{DFFF}])))?|\u{DFFF}(?:\u{200D}(?:[⚕⚖✈]️?|❤️?\u{200D}(?:\u{D83D}\u{DC8B}\u{200D})?\u{D83E}\u{DDD1}\u{D83C}[\u{DFFB}-\u{DFFE}]|\u{D83C}[\u{DF3E}\u{DF73}\u{DF7C}\u{DF84}\u{DF93}\u{DFA4}\u{DFA8}\u{DFEB}\u{DFED}]|\u{D83D}(?:[\u{DCBB}\u{DCBC}\u{DD27}\u{DD2C}\u{DE80}\u{DE92}]|\u{DC30}\u{200D}\u{D83E}\u{DDD1}\u{D83C}[\u{DFFB}-\u{DFFE}])|\u{D83E}(?:[\u{DDAF}\u{DDBC}\u{DDBD}](?:\u{200D}➡️?)?|[\u{DDB0}-\u{DDB3}\u{DE70}]|\u{DD1D}\u{200D}\u{D83E}\u{DDD1}\u{D83C}[\u{DFFB}-\u{DFFF}]|\u{DEEF}\u{200D}\u{D83E}\u{DDD1}\u{D83C}[\u{DFFB}-\u{DFFE}])))?))?|\u{DEF1}(?:\u{D83C}(?:\u{DFFB}(?:\u{200D}\u{D83E}\u{DEF2}\u{D83C}[\u{DFFC}-\u{DFFF}])?|\u{DFFC}(?:\u{200D}\u{D83E}\u{DEF2}\u{D83C}[\u{DFFB}\u{DFFD}-\u{DFFF}])?|\u{DFFD}(?:\u{200D}\u{D83E}\u{DEF2}\u{D83C}[\u{DFFB}\u{DFFC}\u{DFFE}\u{DFFF}])?|\u{DFFE}(?:\u{200D}\u{D83E}\u{DEF2}\u{D83C}[\u{DFFB}-\u{DFFD}\u{DFFF}])?|\u{DFFF}(?:\u{200D}\u{D83E}\u{DEF2}\u{D83C}[\u{DFFB}-\u{DFFE}])?))?)"
        |> Regex.fromString
        |> Maybe.withDefault Regex.never
