# color-clock

A minimal color clock.

Two static HTML files that render time as a 2x2 square of colors.

## 24 hour clock

*Live Preview: https://htmlpreview.github.io/?https://github.com/gatewaycat/color-clock/blob/main/hhmm.html*

A regular 24 hour clock (HHMM) with the following mapping:

0 `#E40303` 1 `#F55A00` 2 `#FF8C00` 3 `#FFBB00` 4 `#FFED00`
5 `#8DB813` 6 `#008026` 7 `#00AAAA` 8 `#004DFF` 9 `#6425CB`

## Equal interval dozenal clock

*Live Preview: https://htmlpreview.github.io/?https://github.com/gatewaycat/color-clock/blob/main/dozenal.html*

Fraction of day in base 12 from 0000 to bbbb with the following mapping:

0 `#E40303` 1 `#F55A00` 2 `#FF8C00` 3 `#FFBB00` 4 `#FFED00` 5 `#8DB813`
6 `#008026` 7 `#00AAAA` 8 `#0088CC` 9 `#004DFF` a `#3A34D6` b `#6425CB`

## Notes

- Pure HTML, CSS, and JavaScript.
- No dependencies.
- Designed to scale cleanly to any viewport.
- Intended as a minimal aesthetic time visualization experiment.
