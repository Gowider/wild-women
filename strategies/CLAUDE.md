# Strategy folder layout

Every strategy lives in its own folder under `strategies/`, named after the
strategy, containing exactly two files named the same as the folder:

```
strategies/
  Triple-Supertrend-49-SMA/
    Triple-Supertrend-49-SMA.pine   # the Pine Script
    Triple-Supertrend-49-SMA.md     # how it trades, inputs, caveats
```

Create the folder first, then add the `.pine` and the `.md` into it. One
strategy per folder — never drop a loose `.pine` at the top of `strategies/`.

Use hyphens rather than spaces in folder and file names so the paths stay easy
to work with from a shell and in URLs.

Do not name the notes file `README.md` — the repository's `.gitignore` excludes
`README.md` at every level, so it would silently never be committed.
