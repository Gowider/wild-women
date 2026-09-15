# Triple Supertrend + SMA filters — session-window strategy

`triple_supertrend_sma49.pine` — Pine Script v5, built for a 5-minute chart.
Paste it into TradingView's Pine Editor and **Add to chart**.

## Entry

1. **All three Supertrends agree.** ATR 12 / mult 3, ATR 10 / mult 1, ATR 11 / mult 2.
   The Supertrend maths is a line-for-line port of the v4 study you sent, so the
   plots match that indicator bar for bar.
   The bar they line up on gets a green **Buy** or red **Sell** label.
2. **The SMAs confirm.** Price must *close* on the trend side of every SMA
   marked as a gate — above for a long, below for a short. That bar gets a blue
   **Confirmed** label. If price is already onside when the three line up,
   agreement and confirmation happen on the same bar and both labels print.
3. **The clock.** The SMAs have 60 minutes (12 bars on a 5-min chart) from the
   alignment bar to confirm. After that the setup is dead until the three
   Supertrends line up again from scratch.
4. **A trading window is open.** Entries only fire inside one of the four
   windows; the shaded background shows them.

## SMA slots

Three independent SMAs, each with its own row of inputs: **on/off**, **length**,
**gate**, **colour**.

| Slot | Default | Gate | Role |
|------|---------|------|------|
| SMA 1 | 49  | yes | the entry signal — price has to close on its trend side |
| SMA 2 | 200 | no  | plotted for context; tick `gate` to make it a second filter |
| SMA 3 | 20  | —   | off, a spare slot |

- **on/off** controls whether the line is drawn.
- **gate** controls whether it has a say in entries. A slot only gates when it
  is both on *and* gated, so switching a slot off also removes it from the entry
  rules.
- With **no** slot gating, there is nothing to confirm: entries fire as soon as
  the three Supertrends agree inside a window, and the Confirmed label is
  suppressed.
- Turning on SMA 2's gate makes the setup need price on the right side of both
  the 49 and the 200 — a much tighter filter, and worth backtesting before you
  commit to it.

Labels only print inside the trading windows by default, so what you see on the
chart matches what the strategy can actually trade. `Only label inside the
trading windows` turns that off if you want to see every agreement.

`Only one entry per alignment` (on by default) stops the strategy re-entering
the same setup after a stop-out. Turn it off if you want it to keep trying while
the three stay aligned and the hour is still running.

## Trading windows

| # | Window | Notes |
|---|--------|-------|
| 1 | 21:45 – 04:45 | rolls across midnight |
| 2 | 05:45 – 08:15 | |
| 3 | 10:30 – 11:30 | |
| 4 | 14:00 – 14:45 | |

### Timezone — read this before you judge a backtest

`Window timezone` decides what clock the window times are read on, and it has
**nothing to do with the timezone your chart displays**. The two being different
is the single most common reason windows look wrong.

`Exchange` on a CME symbol means `America/Chicago`. On an Eastern-time chart
that puts every window an hour away from where you expect it: a 21:45 window
opens at 22:45 on the chart. The default is therefore `America/New_York`.

The **status table** in the top-right corner settles it — the `Script clock` row
is the time the rules are actually being applied at, and the `Window` row names
the window it thinks is open. If the clock row disagrees with the time axis,
that difference is your bug.

## Exits

- **Stop loss** — 20 ticks from the fill. Each window has its own tick input
  (`Window 1 stop` … `Window 4 stop`), all defaulted to 20, and the stop used is
  the one belonging to the window the trade was opened in.
- **Supertrend flip** — the trade is closed at the bar's close once
  `how many` of the three have turned against it. Default **2**, so a single
  Supertrend flipping no longer takes the trade off; set it to 1 for the
  original one-flip rule, or 3 to hold until all three have reversed.
- **Hard EOD exit at 15:30** — flat, no questions.
- **Window close (off by default)** — `Force flat at the end of the entry window`
  also kicks the trade out at the end of the window that opened it.

## The one thing I had to guess

"Each trading window will have its own hard stop" reads two ways, so both are
in the script:

- **Its own stop-loss size** — per-window tick inputs, on by default at 20 ticks
  each. This is the reading I defaulted to, because all four windows end before
  15:30, so a per-window *time* stop would mean the 15:30 EOD exit never fires.
- **Its own hard time exit** — the `Force flat at the end of the entry window`
  switch, off by default.

Flip the switch if the second reading is what you meant.

## Status table

Top-right corner, switchable off. It reports the window timezone in force, the
script clock, the open window, the three Supertrend directions, the state of the
SMA gate (confirmed / waiting with bars left / expired), the open position, the
stop in force, and Pine's own running net P&L and closed-trade count.

That last row is a cross-check: it is read straight from `strategy.netprofit`
and `strategy.closedtrades`. If it disagrees with the Strategy Tester panel, the
panel is stale — reload the script.

## Backtest settings that matter

- `process_orders_on_close` is on, so flip/EOD exits fill at the close of the
  signal bar rather than the next open.
- Default size is 1 contract, no commission or slippage. Add your own in the
  strategy properties before reading anything into the numbers.
- Stops are simulated against the bar's high/low; on a 5-min chart a 20-tick
  stop and an entry can land in the same bar, so TradingView's bar-magnifier
  (or a tick-based check) is worth using before you trust the fill sequence.
