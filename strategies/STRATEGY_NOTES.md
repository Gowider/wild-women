# Triple Supertrend + 49 SMA — session-window strategy

`triple_supertrend_sma49.pine` — Pine Script v5, built for a 5-minute chart.
Paste it into TradingView's Pine Editor and **Add to chart**.

## Entry

1. **All three Supertrends agree.** ATR 12 / mult 3, ATR 10 / mult 1, ATR 11 / mult 2.
   The Supertrend maths is a line-for-line port of the v4 study you sent, so the
   plots match that indicator bar for bar.
   The bar they line up on gets a green **Buy** or red **Sell** label.
2. **The 49 SMA confirms.** Price must *close* above the 49 SMA for a long,
   below it for a short. That bar gets a blue **Confirmed** label. If the SMA is
   already on the right side when the three line up, agreement and confirmation
   happen on the same bar and both labels print.
3. **The clock.** The SMA has 60 minutes (12 bars on a 5-min chart) from the
   alignment bar to confirm. After that the setup is dead until the three
   Supertrends line up again from scratch.
4. **A trading window is open.** Entries only fire inside one of the four
   windows; the shaded background shows them.

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

Times are read in the **chart/exchange timezone** by default. The `Timezone`
input overrides that if your windows are quoted in a different zone — set it
before you judge any backtest.

## Exits

- **Stop loss** — 20 ticks from the fill. Each window has its own tick input
  (`Window 1 stop` … `Window 4 stop`), all defaulted to 20, and the stop used is
  the one belonging to the window the trade was opened in.
- **Supertrend flip** — the moment any one of the three changes colour against
  the position, the trade is closed at that bar's close.
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

## Backtest settings that matter

- `process_orders_on_close` is on, so flip/EOD exits fill at the close of the
  signal bar rather than the next open.
- Default size is 1 contract, no commission or slippage. Add your own in the
  strategy properties before reading anything into the numbers.
- Stops are simulated against the bar's high/low; on a 5-min chart a 20-tick
  stop and an entry can land in the same bar, so TradingView's bar-magnifier
  (or a tick-based check) is worth using before you trust the fill sequence.
