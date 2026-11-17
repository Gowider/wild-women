# Flip + HTF + CDV — Test Build, Nov 17, 2026

**Script:** `Flip-HTF-CDV_2026-11-17_test-build.pine` (Pine Script v6, TradingView)
**Chart:** ES1! (or MES1!), 1-hour, New York time, ETH
**Status:** TEST BUILD — not yet compiled or backtested.
**Built from:** "Flip + HTF" combined strategy v1 (Oct 5, 2026) + the CDV calculation from "CDV Taper Strategy" v1.5.

---

## How the strategy works

Two trading systems run inside one script. Together they hold **one position at a time**. A third piece, the CDV, now acts as a referee on the entries.

### 1. HTF Corridor (order IDs `H Long` / `H Short`)

**The zone.** The zone is the price range between the most recent **10 am POC** and the most recent **2 pm POC** (New York time). Each POC is built from a 30-minute window of volume, sampled with 30-minute intrabar data. The zone updates as soon as a new 10 am or 2 pm POC finishes.

**The secondary (overnight) zone.** This runs from yesterday's 2 pm POC to today's **6 am POC**. It feeds the trend measure and the overnight tags; entries and targets still use the main zone.

**Entries: always trade toward the zone.** At each candle close inside a setup window, while flat:
- A candle that closes **above** the zone sets up a **short** at that candle's POC.
- A candle that closes **below** the zone sets up a **long** at that candle's POC.
- A candle that closes **inside** the zone means wait.

The order rests at the POC. It's a limit order if price is already past the POC, or a stop order if price still has to travel back through it. The order is cancelled if the stop level trades first, at the window's cancel time, or at EOD.

**Setup windows (NY):**

| Window | Setup candles | Unfilled orders cancelled | Direction |
|---|---|---|---|
| 1 (main) | 07:00 – 10:00 | 11:00 (longs also 11:00) | Both |
| 2 (afternoon) | 13:00 – 14:00 | 15:00 | Both |
| 3 (overnight) | 01:00 – 02:00 | 03:00 | Longs only |

**Exits:**
- **Target:** the far edge of the live zone (longs exit at the zone top, shorts at the zone bottom).
- **Stop:** beyond the entry candle's wick, plus a 1-tick buffer. Setups that need more than 10 points of stop are skipped.
- **Breakeven:** once the trade is up 10 points, the stop moves to entry + 1 tick. This happens intrabar, and from there the stop trails price at that distance.
- **EOD:** always flat at 15:30, including early closes and holidays.

**Overnight rules.** These are based on the overnight tags printed on each entry, `6:x W:x O:x S:x`:
- Skip longs after a wide overnight drop (W:W-).
- Skip longs when the 6 am POC is below the zone and the 07:00 open is inside the overnight zone (6:B O:I).
- Skip longs after a normal-width overnight (W:N).
- Skip longs when the 6 am POC is inside the zone (6:I).
- Skip shorts when the 6 am POC is below the zone (6:B).
- Skip the short after a normal-width overnight rally with the open above the overnight zone (W:N+ O:A).
- Size up to 3 contracts on only the two strongest setups: shorts after a wide overnight rally (W:W+) and longs after a tight overnight drift down (T:T-). These entries end in " SZ3".

**Tag key:**
- **6** = 6 am POC vs the zone (A above / I inside / B below).
- **W** = overnight-zone width vs its 20-day average (T tight / N normal / W wide), with + for overnight up and - for overnight down.
- **O** = 07:00 open vs the overnight zone (A / I / B).
- **S** = stair-step vs yesterday's overnight zone (U up / D down / O overlapping).

**Market regime.** Today's overnight zone is compared with yesterday's (the stair-step):
- Stacked above = uptrend day; stacked below = downtrend day; overlapping = balance day.
- On trend days, only setups in the trend's direction are taken.
- The optional Springboard mode reviews 14:00 yesterday to 08:30 today. If yesterday's 10 am POC was never traded through, the zone becomes a launch pad: entries go at the zone edge in the trend direction, with a 2R target and a maximum of 2 per day.

### 2. 4HR Flip (order IDs `F Long` / `F Short`)

**The zones.** Every **10:00 candle** becomes a sweep zone once it closes, using its high, its low and its POC (built from 1-minute data). A zone stays live for today plus the next 2 trading days (D-0, D-1, D-2), and it's used up once it trades.

**Entry: against the sweep.** A later candle trades beyond one edge of a live zone and closes back inside it.
- A swept **low** sets up a **long** at the zone's POC.
- A swept **high** sets up a **short** at the zone's POC.

The newest zone is checked first. A newer sweep replaces an order that is still waiting.

**Exits:**
- **Stop:** beyond the zone edge, plus 3 ticks. Setups needing more than 20 points of stop are skipped.
- **Breakeven:** once the trade is up 15 points, the stop moves to entry + 8 ticks. This is checked at candle close.
- **No profit target.** Trades exit at the flats:
  - Trades entered overnight (18:00–09:00) are flattened at **09:00**.
  - Everything else is flat at **15:30**.
- **Reverse:** an opposite sweep closes the trade and flips it at market on the next candle open.
- **Trend-day hold:** on a trend day (daily efficiency ratio > 0.30 over 20 days), sweeps of D-1 and older zones are ignored while in a trade, so they cause no reversal. Today's D-0 zone can still reverse the trade.

**Limits:**
- Maximum 2 trades per session.
- Unfilled orders are cancelled at 15:00.
- No new setups from 15:00 to 18:00.
- Entries are blocked 13:00–18:00 (Block A) and 20:00–02:00 (Block B).

### 3. How the two systems share one account

- **Stay in the trade you're in.** While one system holds a trade, the other sets up nothing until the position is flat.
- **One-cancels-other.** While flat, both systems can have an order resting. They share one OCA group, so the first to fill cancels the other.
- **Same candle.** If both systems set up a new trade on the same candle, the **Same-Candle Priority** system keeps its order. The default is HTF Corridor.
- Every entry and exit is labelled "HTF …" or "FLIP …" for analysis.

### 4. NEW in this build: CDV confirmation

The CDV from the CDV Taper Strategy (LonesomeTheBlue math, Heikin Ashi CDV, green 20 / red 50 lines) is calculated inside this script. It isn't drawn on the chart; its values are in the Data Window.

- **HTF Corridor entries** (zone and springboard) now only set up when the CDV agrees:
  - **Longs** need green over red (buyers in control).
  - **Shorts** need red over green (sellers in control).
- **"CDV must agree by"** can instead use the HA CDV candle color, or require both the lines and the candle color.
- **4HR Flip entries:** the same filter is available but **off** by default.
- **CDV Timeframe:**
  - Blank = the chart's own timeframe.
  - A higher timeframe (for example 240) reads only that timeframe's last *completed* candle, so it never repaints.
  - A timeframe lower than the chart is ignored, and the chart timeframe is used.

### 5. NEW in this build: entry hours and days

These are checkboxes for each NY hour (00–23) and each day (Sun–Fri) that gate new setups in **both** systems. They're judged by the hour and day the order could first fill, which is the setup candle's close time. All are on by default (any hour), ready for refining after the first test.

---

## All settings (script defaults)

### Properties (set in the `strategy()` line; editable in the Properties tab)

| Setting | Default |
|---|---|
| Initial capital | 1,000,000 USD |
| Order size | 2 contracts (fixed) |
| Pyramiding | 0 |
| Commission | $2.50 per contract (per side) |
| Process orders on bar close | Off |

### Combined

| Setting | Default |
|---|---|
| Hide ALL Trade Signals (for recording) | Off |
| Same-Candle Priority | HTF Corridor |

### CDV Confirmation (new)

| Setting | Default |
|---|---|
| Confirm HTF Corridor entries with CDV | On |
| Confirm 4HR Flip entries with CDV | Off |
| CDV must agree by | CDV lines (green vs red) |
| CDV Timeframe | blank (chart) |
| Line type | SMA |
| Green (fast) length | 20 |
| Red (slow) length | 50 |

### Entry Hours (New York) / Entry Days (New York) (new)

| Setting | Default |
|---|---|
| Hours 00 – 23 | All on |
| Sun, Mon, Tue, Wed, Thu, Fri | All on |

### HTF · Trading Mode

| Setting | Default |
|---|---|
| Enable Trading | On |
| Hide All Trade Signals (for recording) | Off |
| Show Overnight Tags on Chart | On |
| Tag Entries with Overnight Context | On |

### HTF · Overnight Rules

| Setting | Default |
|---|---|
| Skip Longs After a Wide Overnight Drop | On |
| Skip Longs: 6 am POC Below Zone + Open Inside Overnight Zone (6:B O:I) | On |
| Skip Longs After a Normal-Width Overnight (W:N) | On |
| W:N+ O:A Short Setup | Skip (no trade) |
| Trend Long Target (R multiple) | 2.0 |
| Skip Longs: 6 am POC Inside the Zone (6:I) | On |
| Skip Shorts: 6 am POC Below the Zone (6:B) | On |
| Size Up the Two Strongest Overnight Setups | On |
| Contracts for Strong Setups | 3 |

### HTF · POC

| Setting | Default |
|---|---|
| Intrabar Resolution | 30 min |
| Row Size (ticks) | 4 |
| Max Rows per Candle | 400 |

### HTF · Zone

| Setting | Default |
|---|---|
| Time Zone | America/New_York |
| Zone POC 1 | 10:00 |
| Zone POC 2 | 14:00 |
| Zone POC Window (minutes) | 30 |
| Show 10 am / 2 pm POC Lines | On |
| 10 am colors: today / yesterday | White / Blue |
| 2 pm colors: today / yesterday | Yellow / Orange |
| Key Line Width | 2 |
| Shade the Zone | On (gray) |

### HTF · Secondary Zone

| Setting | Default |
|---|---|
| Show Secondary Zone (2 pm -> 6 am) | On |
| Secondary POC | 06:00 |
| 6 am colors: today / yesterday | Aqua / Teal |
| Secondary Zone Shading | Purple |

### HTF · Session

| Setting | Default |
|---|---|
| First Setup Candle | 07:00 |
| Last Setup Time | 10:00 |
| Cancel Unfilled Orders | 11:00 |
| EOD Flat | 15:30 |
| Skip Thursdays | Off |
| Cancel Unfilled LONG Orders | 11:00 |

### HTF · Extra Windows

| Setting | Default |
|---|---|
| Window 2 (afternoon) | On |
| W2 First Setup Candle / Last Setup Time / Cancel | 13:00 / 14:00 / 15:00 |
| W2 Direction | Both |
| Window 3 (overnight) | On |
| W3 First Setup Candle / Last Setup Time / Cancel | 01:00 / 02:00 / 03:00 |
| W3 Direction | Longs only |

### HTF · Risk

| Setting | Default |
|---|---|
| Direction | Both |
| Contracts | 2 |
| Stop Buffer (ticks beyond entry candle wick) | 1 |
| Max Stop Size (points, 0 = off) | 10 |
| Min Distance Entry -> Target (ticks) | 10 |
| Breakeven Trigger (points) | 10 |
| Breakeven Lock (ticks past entry) | 1 |
| Breakeven Timing | Intrabar |

### HTF · Market Regime

| Setting | Default |
|---|---|
| Market Regime Filter | With-trend only on trending days |
| Trend Measure | Overnight zone stair-step |
| Stair-step: Overlap Tolerance (ticks) | 0 |
| Lookback (daily candles) | 3 |
| Trending if % change > | 3.0 |
| Trending if efficiency ratio > | 0.20 |
| Tint Trending Days | On (red) |

### HTF · Springboard

| Setting | Default |
|---|---|
| Review From (previous day) | 14:00 |
| Review To | 08:30 |
| Springboard Target (R multiple) | 2.0 |
| Max Springboard Trades per Day | 2 |
| Springboard / Waiting tints | Green / Gray |

### HTF · Display

| Setting | Default |
|---|---|
| Dot on Each Candle's POC | On (#ffe100) |
| Show Entry / Stop Lines | On (entry yellow, stop red) |
| Show Entry/Exit Text | On |

### FLIP · Trading

| Setting | Default |
|---|---|
| Enable Trading | On |
| Hide All Trade Signals (for recording) | Off |
| Contracts | 2 |
| Direction | Both |
| Time Zone | America/New_York |
| Zone Candle | 10:00 |
| Days Back (0-5) | 2 |
| Reverse on an Opposite Signal | On |
| Reversal Entry | Market (next candle open) |
| Max Trades per Session (0 = no limit) | 2 |
| Cancel an Unfilled Order After (candles, 0 = off) | 0 |
| Sweep Must Close Back Inside the Zone | On |
| Cancel Unfilled Orders | 15:00 |
| Flat At | 15:30 |
| Separate Flat Time for Overnight Trades | On |
| Overnight Trades Flat At | 09:00 |
| Overnight Entries From / Until | 18:00 / 09:00 |
| Block Entries — Window A | On, 13:00 – 18:00 |
| Block Entries — Window B | On, 20:00 – 02:00 |

**Locked in the code (not on the settings panel since v13):**
- Entry window: off.
- Longs overnight only: off.
- Target: none (exit at the flats).
- Trailing stop: off.
- Hold-with-trend-only: off.
- 2 pm candle lines: off.
- 2 pm / 6 am POC window: 60 min.

### FLIP · Risk

| Setting | Default |
|---|---|
| Stop | Beyond the zone edge |
| Stop Buffer (ticks) | 3 |
| Max Stop (points, 0 = off) | 20 |
| Breakeven Stop | On |
| Breakeven Trigger (points in profit) | 15 |
| BE+ Ticks | 8 |

### FLIP · Market Regime

| Setting | Default |
|---|---|
| Trend Day: Hold Trades Through Opposite Sweeps | On |
| Zones Ignored While in a Trade | Previous-session zones (D-1 and older) |
| Trend Measure | Efficiency ratio |
| Stair-step: Overlap Tolerance (ticks) | 3 |
| Lookback (daily candles) | 20 |
| Trending if % change > | 3.0 |
| Trending if efficiency ratio > | 0.30 |
| Tint Trend Days | On (uptrend green / downtrend red) |

### FLIP · Display

| Setting | Default |
|---|---|
| Shade the Previous Day's 10 am Zone | On (yellow), zone POC lime |
| Candle POC Dots | On (#ffe100) |
| Candle VAH / VAL Marks | On (VAH aqua, VAL fuchsia) |
| Shade Each Candle's Value Area | On (gray) |
| 10 am Candle High & Low Lines (until crossed) | On (white) |
| Keep Crossed Lines | On |

### FLIP · Candle Profile

| Setting | Default |
|---|---|
| Intrabar Resolution | 1 min |
| Row Size (ticks) | 4 |
| Value Area % | 70 |

---

## Before testing: things to know

1. **This build is based on the Oct 5 "Flip + HTF" v1 file, not the Oct 8 keeper.** The keeper is "Flip + HTF 10.8.26", v24. Two differences matter:
   - **Hide ALL Trade Signals turns trading OFF in this file.** That was the "no trades" problem fixed in v24.
   - **The FLIP · Monster Move group is not in this file.**

   If the keeper is the base you want, the CDV filter and the entry hours/days should be added to the v24 file instead.

2. **Where the keeper settings (Oct 8, ES 1h, +$141,655 / 365 days) differ from these defaults:**

   | Setting | This build's default | Keeper |
   |---|---|---|
   | Same-Candle Priority | HTF Corridor | 4HR Flip |
   | HTF skip longs after wide drop / 6:B O:I / W:N / 6:I | On | Off |
   | HTF size up strongest setups | On | Off |
   | HTF stop buffer | 1 tick | 2 ticks |
   | HTF Window 3 direction | Longs only | Both |
   | FLIP sweep must close back inside | On | Off |
   | Properties: bar detalization / execute on bar close | — | High / On |

3. **Timeframe.**
   - The HTF and Flip engines are clock-based (10 am, 2 pm, 6 am), so they trade on **intraday charts only**.
   - On charts below 30 minutes, set *HTF · POC → Intrabar Resolution* to the chart's timeframe or lower.
   - The CDV filter works on any timeframe.
