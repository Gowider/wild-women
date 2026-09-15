# Trade analysis — MES, 2026-08-17 to 2026-09-15

Source: TradingView list-of-trades export, `3xST+SMA49`, CME_MINI:MES1!,
91 trades (90 closed, 1 open), 25 trading days, 20 contracts, ~$750k account.

---

## Headline

| | |
|---|---|
| Net P&L | **+$6,500** (+0.65%) |
| Trades | 90 closed |
| Win rate | **14.4%** (13 winners) |
| Profit factor | 1.16 |
| Avg win / avg loss | $3,700 / $540 (6.9 : 1) |
| Peak equity | +$15,825 (Aug 24) |
| Max drawdown | **-$17,450** |
| Longest losing streak | **19 trades** (Sep 3 – Sep 10) |

The drawdown is larger than the peak profit. The strategy made all of its money
in the first six trading days and has been giving it back since.

## The number that decides everything: costs

The backtest charged **$0 commission and modelled no slippage**. 90 trades at 20
contracts is 1,800 contract round turns.

| Commission /RT | Slippage | Total cost | Net after cost |
|---|---|---|---|
| $0.62 | 0 ticks | $1,116 | +$5,384 |
| $1.24 | 1 tick | $4,482 | +$2,018 |
| $1.24 | 2 ticks | $6,732 | **-$232** |
| $1.74 | 2 ticks | $7,632 | **-$1,132** |

A 20-tick stop being hit on 20 contracts is a stop-market order in a fast move —
one tick of slippage is optimistic, not pessimistic. **As it stands this is a
break-even-to-losing system once you pay to trade it.** Every improvement below
has to clear that bar, not the $6,500.

---

## What worked

**Trades that survive.** Duration is the single cleanest split in the data:

| Duration | Trades | Net | Win% |
|---|---|---|---|
| 1 bar | 11 | -$8,600 | 0% |
| 2 bars | 19 | -$8,600 | 5% |
| 3–4 bars | 22 | -$11,000 | 0% |
| 5–8 bars | 10 | -$5,000 | 0% |
| 9–16 bars | 12 | -$3,975 | 8% |
| **17+ bars** | **16** | **+$43,675** | **69%** |

Everything under four hours loses. The entire edge is 16 trades that got past
the noise and ran.

**The EOD exit.** It is the only exit that makes money:

| Exit | Trades | Net | Win% |
|---|---|---|---|
| EOD 15:30 | 14 | **+$47,700** | 93% |
| Long stop | 35 | -$17,925 | 0% |
| Short stop | 41 | -$23,275 | 0% |

**The overnight window.** By entry clock, window 1 carries the strategy:

| Window | Trades | Net | Win% |
|---|---|---|---|
| W1 21:45–04:45 | 40 | **+$10,850** | 18% |
| W2 05:45–08:15 | 9 | -$425 | 11% |
| W3 10:30–11:30 | 6 | -$3,000 | 0% |
| W4 14:00–14:45 | 2 | -$100 | 50% |
| outside any window | 33 | -$825 | 12% |

**Direction by session.** Shorts overnight, longs in the day:

| | Long | Short |
|---|---|---|
| Night (19:00–06:00) | -$2,050 | **+$10,900** |
| Day (06:00–19:00) | **+$3,950** | -$6,300 |

That is almost certainly the August–September downtrend showing through rather
than a structural effect — treat it as a hypothesis, not a rule.

## What didn't

**The Supertrend exit never fires.** Every one of the 90 exits was a stop or the
EOD flat. **Zero** trades exited on a Supertrend flip. With a 20-tick stop on
15-minute bars, price reaches the stop long before two of three Supertrends
turn. The exit logic you designed is dead code in this configuration.

**The 20-tick stop is far too tight for the bar size.** 76 of 77 losers are the
same -$500 stop-out. The stop is not selecting bad trades out; it is a
near-random 5-point coin flip that the entry has no edge against.

**Give-back is the biggest single leak.** Losers that were in profit first:

| Peak open profit before losing | Trades | Lost | Open profit given back |
|---|---|---|---|
| $500–$1,000 | 15 | -$7,500 | $10,750 |
| $1,000–$2,000 | 8 | -$4,000 | $12,450 |
| $2,000+ | 4 | -$2,000 | $10,600 |

**27 losing trades were up a full 1R ($500) or more before being stopped for a
full loss.** One of them was up $3,925.

**Over-trading on chop days.**

| Trades taken that day | Days | Net |
|---|---|---|
| 1–3 | 13 | **+$19,900** |
| 4+ | 12 | **-$13,400** |

Once a day has produced four signals, the day is chopping and every further
signal is noise.

**Worst hours** (entry clock): 01:00 (10 trades, 0 wins, -$5,050), 10:00 (6
trades, 0 wins, -$3,600), 19:00–20:00 and 22:00 (11 trades, 0 wins, -$5,675).

---

## Two things to fix before trusting any of this

**1. This ran on a 15-minute chart, not the 5-minute you specified.** Every
intraday trade in the export works out to exactly 15.0 minutes per bar. That
changes what a 20-tick stop means and it changes the Supertrend values
completely.

**2. The trading windows were not being enforced in this run.** At *no* clock
offset do more than 68% of entries fall inside the four windows — 33 trades are
outside all of them regardless of timezone assumption. Either this export
predates the timezone fix or the windows were off. Worth confirming before
reading anything into the per-window table.

---

## Changes, ranked by evidence

Applied cumulatively to this dataset:

| Rule | Trades | Net |
|---|---|---|
| baseline | 90 | +$6,500 |
| + honour the four windows | 57 | +$7,325 |
| + max 3 trades per day | 49 | +$10,425 |
| + move stop to breakeven at +1R | 49 | **+$19,425** |

1. **Move the stop to breakeven once the trade is up 1R.** Biggest single
   improvement: rescues 18–27 losers, ~+$9,000–13,500. It attacks the give-back
   leak directly and costs nothing when trades work.
2. **Cap trades per day at 3.** +$3,100 on this sample and it caps the tail risk
   that produced the 19-trade losing streak.
3. **Widen the stop or shrink the bar.** A 20-tick stop on 15-minute bars is
   inside the noise. Either go to the 5-minute chart you designed this for, or
   size the stop off ATR (e.g. 1.0–1.5x ATR(14)) so it scales with the bar.
4. **Make the Supertrend exit reachable.** With the current stop it never fires.
   If a wider stop lets trades breathe, the flip exit starts doing its job —
   that is the change most likely to convert some of the 74 stop-outs.
5. **Add a trailing stop behind the EOD exit.** Winners captured 75% of their
   peak open profit ($48,100 of $63,800). That last 25% is worth chasing only
   after the leaks above are closed.

## Caveats — read these before acting

- **90 trades, 13 winners, 25 trading days.** That is a very thin sample. The
  per-window and per-hour tables have cells with 2 and 6 trades in them.
- **Excluding specific hours would be curve-fitting.** The hours that lost here
  have no structural reason to keep losing. The day-count cap and the breakeven
  stop are behavioural rules that generalise; "don't trade the 10:00 hour" is a
  story about one month of data.
- **One month, one regime.** August–September 2026 was a downtrend, which is
  why shorts look better. Test across a full quarter at minimum before sizing up.
- **The what-if figures assume the breakeven stop would not have taken winners
  out early.** On this data no winner retraced through its entry after reaching
  1R, but on other data some will. Treat +$19,425 as an upper bound.
