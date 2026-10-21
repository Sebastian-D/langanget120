-- PDF only: put each photo in a narrow right-hand column next to the text it
-- belongs to, instead of on its own full-width line.
--
-- The pages place a photo right after the text it shows, so a photo is paired
-- with the blocks before it, back to the previous heading or photo. Blocks after
-- the last photo in a section are added beside that photo too. A section's
-- text never moves past a heading.

local IMAGE_COLUMN = "4.5cm"

local function is_boundary(block)
  return block.t == "Header" or block.t == "HorizontalRule"
end

local function side_by_side(text_blocks, figure)
  local out = pandoc.List({
    pandoc.RawBlock("typst",
      "#grid(columns: (1fr, " .. IMAGE_COLUMN .. "), column-gutter: 1.5em, [")
  })
  out:extend(text_blocks)
  out:insert(pandoc.RawBlock("typst",
    '], [#set image(width: 100%, height: 8.5cm, fit: "contain")'))
  out:insert(figure)
  out:insert(pandoc.RawBlock("typst", "])"))
  return out
end

-- Lay out one section (the blocks between two headings).
local function layout_section(blocks)
  local groups = pandoc.List() -- { text = List, figure = Figure }
  local text = pandoc.List()
  for _, block in ipairs(blocks) do
    if block.t == "Figure" then
      groups:insert({ text = text, figure = block })
      text = pandoc.List()
    else
      text:insert(block)
    end
  end
  if #groups == 0 then
    return text
  end
  groups[#groups].text:extend(text)

  local out = pandoc.List()
  for _, g in ipairs(groups) do
    if #g.text > 0 then
      out:extend(side_by_side(g.text, g.figure))
    else
      out:insert(g.figure)
    end
  end
  return out
end

function Pandoc(doc)
  if not quarto.doc.is_format("typst") then
    return nil
  end

  local out = pandoc.List()
  local section = pandoc.List()
  for _, block in ipairs(doc.blocks) do
    if is_boundary(block) then
      out:extend(layout_section(section))
      section = pandoc.List()
      out:insert(block)
    else
      section:insert(block)
    end
  end
  out:extend(layout_section(section))

  doc.blocks = out
  return doc
end
