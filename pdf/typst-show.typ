// Replaces Quarto's orange-book typst-show.typ partial with a plain layout:
// cover page, table of contents on page 2, and each chapter on a new page with
// its own colour. Figure counters are still reset per chapter by Quarto.

#let primary = brand-color.at("primary", default: rgb("#2C3E50"))
#let muted = brand-color.at("secondary", default: gray)

// Chapter colours, by chapter number (palette names from _brand.yml).
// `tab` fills the thumb tab, `text` colours headings, `on` is the tab's number.
#let chapter-palette = (
  (tab: "ultimate-gray", text: "ultimate-gray-text", on: black),
  (tab: "classic-blue", text: "classic-blue", on: white),
  (tab: "mocha-mousse", text: "mocha-mousse-text", on: white),
  (tab: "viva-magenta", text: "viva-magenta", on: white),
  (tab: "illuminating", text: "illuminating-text", on: black),
  (tab: "very-peri", text: "very-peri", on: white),
)
#let chapter-colors(n) = {
  if n < 1 { return (tab: primary, text: primary, on: white) }
  let c = chapter-palette.at(calc.rem(n - 1, chapter-palette.len()))
  (
    tab: brand-color.at(c.tab, default: primary),
    text: brand-color.at(c.text, default: primary),
    on: c.on,
  )
}
// The numbered chapter a page belongs to (needs context), or none.
#let page-chapter() = {
  let p = here().page()
  let started = query(heading.where(level: 1))
    .filter(h => h.numbering != none and h.location().page() <= p)
  if started.len() > 0 { started.last() } else { none }
}

$if(brand.typography.base.family)$
#set text(font: $brand.typography.base.family$)
$endif$
#set text(size: 10.5pt$if(lang)$, lang: "$lang$"$endif$)
#set par(leading: 0.65em, spacing: 1.1em)

#set heading(numbering: "1.1")

// All headings take their chapter's colour. `show text` is needed to win over
// the brand's heading colour, which Quarto sets with an earlier show rule.
#show heading: it => context {
  let c = chapter-colors(counter(heading).get().first()).text
  show text: set text(fill: c)
  it
}
// Chapter headings: new page, number and title with a thin rule underneath.
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  context {
    let c = chapter-colors(counter(heading).get().first()).text
    block(width: 100%, below: 1.4em, {
      set text(size: 1.7em, fill: c)
      if it.numbering != none {
        counter(heading).display("1.")
        h(0.4em)
      }
      it.body
      v(0.25em)
      line(length: 100%, stroke: 0.8pt + c)
    })
  }
}
#show heading.where(level: 2): set block(above: 1.8em, below: 0.9em)
#show heading.where(level: 3): set block(above: 1.4em, below: 0.8em)

// Chapter-based figure numbers (Figur 2.1); Quarto resets the counters per chapter.
#set figure(numbering: num => numbering("1.1", counter(heading).get().first(), num))
#show figure.caption: set text(size: 0.85em, fill: muted.darken(40%))

// Photos that are not placed beside text (see pdf/side-images.lua).
#set image(height: 8cm)

#set page(
  // Running header with the chapter name, left out on the chapter's first page.
  header: context {
    let h = page-chapter()
    if h != none and h.location().page() != here().page() {
      let n = counter(heading).at(h.location()).first()
      set text(size: 0.8em, fill: chapter-colors(n).text)
      align(right)[#n. #h.body]
    }
  },
  footer: context align(center, text(size: 0.85em, counter(page).display())),
  // Thumb tab on the right edge, one slot per chapter from top to bottom.
  background: context {
    let h = page-chapter()
    if h != none {
      let n = counter(heading).at(h.location()).first()
      let c = chapter-colors(n)
      let slot = (page.height - 5cm) / chapter-palette.len()
      place(top + right, dy: 2.5cm + (n - 1) * slot,
        rect(width: 7mm, height: slot - 2mm, fill: c.tab, inset: (right: 2mm),
          align(center + horizon,
            text(size: 9pt, weight: "bold", fill: c.on, str(n)))))
    }
  },
)

#page(header: none, footer: none, align(center + horizon)[
  #text(size: 3em, weight: "bold", fill: primary)[$title$]
$if(by-author)$
  #v(1em)
  #text(size: 1.4em)[$for(by-author)$$it.name.literal$$sep$, $endfor$]
$endif$
])

$if(toc)$
#show outline.entry.where(level: 1): it => context {
  let n = counter(heading).at(it.element.location()).first()
  show text: set text(fill: chapter-colors(n).text, weight: "bold")
  it
}
#outline(depth: $if(toc-depth)$$toc-depth$$else$2$endif$, indent: auto)
#pagebreak()
$endif$
