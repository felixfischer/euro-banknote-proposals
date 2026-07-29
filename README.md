# Euro Banknote Design Proposals — Viewer

A single-file HTML viewer for the ten design proposals (A–J) that the European Central Bank
published for the future euro banknote series.

**This is a frontend, nothing more.** The designs, the images and every idea in them belong to
their creators. This repository exists only because comparing the proposals on the official page
means a lot of scrolling and clicking, and I wanted to see all six denominations — front and back —
of one proposal at a glance.

## What it does

- All six denominations (€5–€200) of a proposal on one screen, front and back paired in one box
- Layout follows the artwork: landscape designs stack the two sides vertically, portrait designs
  (**D, G, I, J**) place them side by side
- Switch proposals with the tabs, the arrow keys, or by pressing `A`–`J`
- **Compare** view: the same denomination across all ten proposals at once
- Filter to front or back only, adjustable card size, click any note for a full-size view
- No build tooling, no dependencies, no tracking — one `index.html` that also runs straight from
  the local filesystem

## Running it locally

```bash
bash download.sh          # fetches 120 JPEGs into ./images/
open index.html           # or just double-click it
```

Images land in `images/<PROPOSAL>/<PROPOSAL>-<denomination>-<side>.jpg`, e.g. `images/D/D-50-back.jpg`.

If a local file is missing, the viewer transparently falls back to loading that image directly from
`ecb.europa.eu`, so `index.html` also works entirely on its own — it just depends on the ECB keeping
those URLs alive.

## Deploying

`build.sh` assembles a `dist/` directory containing `index.html` plus the images, which it downloads
from the ECB **at build time**. Nothing image-related is ever committed to the repository.

```bash
bash build.sh             # -> ./dist, ready to upload anywhere
SKIP_IMAGES=1 bash build.sh   # -> ./dist without images (viewer hotlinks the ECB instead)
```

Both configured targets are zero-touch:

### Render

`render.yaml` is a blueprint. Push the repo to GitHub, then in Render pick **New → Blueprint** and
select it — build command, publish path and cache headers come from the file. Static sites are free
and pull-request previews are enabled.

### GitHub Pages

`.github/workflows/pages.yml` builds and publishes on every push to `main`. Enable it once under
**Settings → Pages → Source → GitHub Actions**. The workflow caches the downloaded images between
runs, so only the first deploy pays the download cost. Relative paths mean the project-subpath URL
(`https://<user>.github.io/<repo>/`) works without extra configuration.

### Anything else

Any static host works with the same two settings:

| Setting | Value |
| --- | --- |
| Build command | `bash build.sh` |
| Publish directory | `dist` |

That covers Netlify, Cloudflare Pages, Vercel, Surge and a plain `rsync` to your own server. The
build needs nothing but `bash` and `curl`.

## Rights and attribution

- **I claim no rights whatsoever to the banknote designs or their images.** They were created by the
  design teams commissioned in the ECB's design competition, and they are published by the European
  Central Bank on its own website.
- The images are **not part of this repository**. They are fetched from the ECB's servers — into
  your working copy when you run `download.sh`, or into the build output when a deployment runs
  `build.sh`.
- Nothing here is an official ECB product, and it is not affiliated with or endorsed by the ECB. For
  the authoritative presentation, the designers' names, the full descriptions and the current state
  of the selection process, always refer to the source:

  <https://www.ecb.europa.eu/euro/banknotes/future_banknotes/html/design-proposals.en.html>

- If any rights holder objects to this viewer or to the way it uses the images, open an issue and it
  will be taken down.
- The code in this repository is released under the MIT license — see `LICENSE`. That license covers
  **only** the code, never the artwork.

## A note on proposal D

Proposal D is a portrait design, but the ECB serves some of its images — the six reverse sides in
particular — as landscape JPEGs without an EXIF orientation flag, so browsers render them lying on
their side. The viewer detects this at load time: if a proposal is portrait but the decoded image is
wider than it is tall, that image is rotated 90° clockwise in the layout. The downloaded files are
never modified.

## Files

```
index.html                      the viewer (HTML, CSS and JS in one file)
download.sh [dir]               fetches the images into <dir>/images/
build.sh [out]                  assembles ./dist for deployment
render.yaml                     Render blueprint
.github/workflows/pages.yml     GitHub Pages deployment
images/, dist/                  generated, git-ignored
```

## Status

The ECB has not selected a final design; the proposals are candidates. Treat everything here as a
snapshot of publicly available material at the time of download.
