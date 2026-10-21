# CLAUDE.md

## What this is

A small Quarto website (in Swedish) with house-manual instructions for the property Långänget 120. The content comes from a series of walkthrough videos in which the previous owner, Tobias Kock, explains how the systems work. Each page turns one or more videos into a written guide with photos.

Not a git repository. No code, tests or build scripts: only `.qmd` pages, images and raw media.

## Commands

```sh
quarto preview                  # live preview of the website
quarto render                   # build the website into _site/
quarto render --profile pdf     # build one combined PDF into _pdf/ (named after book.title)
```

`_site/`, `_pdf/` and `.quarto/` are generated output. Never edit them by hand.

## Layout

The config is split into two [project profiles](https://quarto.org/docs/projects/profiles.html) in a profile group, so exactly one of them is active (website is the default):

- `_quarto.yml`: shared settings only (the profile group, `lang: sv`).
- `_quarto-website.yml`: `project: website`, the navbar, and HTML format (theme `flatly` + `brand`, `toc: true`).
- `_quarto-pdf.yml`: `project: book` with Typst output. The `chapters` list sets the PDF order.
- **A new page must be added to both the navbar in `_quarto-website.yml` and `chapters` in `_quarto-pdf.yml`.**
- `_brand.yml`: colours (Flatly's palette) and the Lato font, shared by both outputs.
- `pdf/typst-show.typ`: replaces the `typst-show.typ` partial of Quarto's orange-book book format, so orange-book's `book()` layout is not used at all. It defines the whole PDF look: cover page, table of contents on page 2, each chapter on a new page (no blank pages), chapter headings with a thin rule, running header, page numbers, chapter-based figure numbers. Each chapter has its own colour for headings, header, TOC entry and a numbered thumb tab on the right edge. `chapter-palette` maps chapter numbers to palette names in `_brand.yml` (Pantone Colors of the Year, with darkened `*-text` variants for readable text). A seventh chapter would reuse colour 1, so add a palette entry along with the page. If a Quarto upgrade breaks the PDF build, compare it with `/Applications/quarto/share/extension-subtrees/orange-book/_extensions/orange-book/typst-show.typ`.
- `pdf/side-images.lua`: PDF-only filter. Within each section (blocks between headings), each photo goes in a 4.5 cm right-hand column beside the text before it. Text after the last photo of a section joins that photo's group. That is why photos should stay right after the text they show.
- `index.qmd`: short landing page (chapter 1 in the PDF).
- One `.qmd` per system:

  | Page | Topic | Source videos (`media/`) |
  |---|---|---|
  | `varmvattenberedare.qmd` | Water heater under the cabin: main shut-off valve, coarse water filter | `varmvattenberedare_under_stugan.mp4` |
  | `vattenstugan.qmd` | Water hut on the plot: shut-off valve, draining for winter, glycol in traps, turning water back on | `vattenstugan_tomt.mp4`, `vattenstugan_kranar.mp4` |
  | `badtunna.qmd` | Hot tub: wood stove, pump timer, filter backwash, winterising | `badtunna_*.mp4` |
  | `värmekabel.qmd` | Heating cables along the water pipes, earth-fault breaker | `värmekabel.mp4` |
  | `luftvarmvattenberedare.qmd` | Air-source water heater in the bathroom: temperature, heat exchanger "turbo", immersion heater, underfloor heating, glycol refill, winter shutdown | `luftvarmvattensberedare*.mp4`, `glykol_*.mp4` |

- `images/<page>/`: photos used on the pages (mostly stills picked from the video frames), with short descriptive kebab-case names such as `images/badtunna/timer.jpg`.
- `styles.css`: empty placeholder.

### `media/` (raw source material, about 5 GB)

Not referenced by the site. Used only to write and check page content.

- `*.mp4`: the original videos.
- `media/<video>/`: what was extracted from each video: `audio.wav` (16 kHz mono), `transcript.srt`, `frames/frame_NNNN.jpg` (stills taken every few seconds) and usually `sheet.jpg` (contact sheet of the frames). `media/badtunna/` has one subfolder per hot-tub video (`filter`, `kamin`, `timer`, `vatten`).
- `media/transcript.srt|json`, `media/audio.wav`, `media/frames/*.png`: from the earlier `varmvattenberedare_under_stugan.mp4` run, before the per-video folder layout was used.
- `media/whisper-models/ggml-medium.bin`: the whisper.cpp model used for transcription.

Folder names drop å/ä/ö (`varmekabel`, `luftvarmvattensberedare_avstangning`), while some video filenames keep them.

## Processing a new video

The tools are installed: `ffmpeg` (Homebrew) and `whisper-cli` (whisper.cpp). No script for this was saved. The commands below were pieced together from the outputs and may not match exactly what was run (the frame rate, for example, varied between videos):

```sh
mkdir -p media/<name>/frames
ffmpeg -i media/<name>.mp4 -ar 16000 -ac 1 media/<name>/audio.wav
whisper-cli -m media/whisper-models/ggml-medium.bin -l sv -osrt -of media/<name>/transcript media/<name>/audio.wav
ffmpeg -i media/<name>.mp4 -vf fps=1/3 media/<name>/frames/frame_%04d.jpg
```

Then read the transcript, look at the frames, copy the useful stills into `images/<page>/` with descriptive names, and write or extend the page.

## Writing conventions

- Write everything in Swedish. Turn the spoken, rambling transcript into clear instructions. Whisper misspells words (e.g. "jordfälsbryta" for jordfelsbrytare), so fix them.
- Page structure: a `title` in the front matter, an optional `Plats: …` line, a one-sentence summary starting with "Guide till …", then `##` sections per task (usually ending with `## Inför vintern`).
- Steps go in numbered lists. Use **bold** for key settings, values and warnings (e.g. **60 grader**, **en kvart**).
- Use Quarto callouts with a `##` heading for tips and warnings: `.callout-note`, `.callout-tip` (often "Hur ofta?"), `.callout-warning`, `.callout-important`.
- Images: `![Full-sentence Swedish caption.](images/<page>/<name>.jpg)` placed right after the text it shows.
- Link between pages with relative `.qmd` links, and give a section an explicit anchor when another page links to it (e.g. `vattenstugan.qmd#glykol-vattenlas`).
- Refer to the previous owner as "Tobias" when describing his habits ("Tobias har alltid kört den på 60 grader").
- Stick to what the videos say. Do not add technical advice that is not in the source.
