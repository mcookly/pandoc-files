-- Extract the important metadata information
local meta = {
  institution = '',
  title = '',
  submission = '',
  author = '',
  date = '',
}

function Meta(m)
  for k, v in pairs(meta) do
    if m[k] ~= nil then
      meta[k] = pandoc.utils.stringify(m[k])
    end
  end

  m['link-bibliography'] = false

  return m
end

function Pandoc(p)
  -- Citeproc needs to be run first so it has all the metadata.
  local doc = pandoc.utils.citeproc(p)

  local blocks = pandoc.List:new()

  blocks:insert(pandoc.Div(
    pandoc.Para(meta.institution),
    { ['custom-style'] = 'Institution' }
  ))

  blocks:insert(pandoc.Div(
    pandoc.Para(meta.title),
    { ['custom-style'] = 'Title' }
  ))

  blocks:insert(pandoc.Div(
    pandoc.Para(meta.submission),
    { ['custom-style'] = 'Submission' }
  ))

  blocks:insert(pandoc.Div(
    pandoc.Para(meta.author),
    { ['custom-style'] = 'Author' }
  ))

  blocks:insert(pandoc.Div(
    pandoc.Para(meta.date),
    { ['custom-style'] = 'Date' }
  ))

  blocks:extend(doc.blocks)

  -- For papers with no citations, no bibliography editing is needed.
  if blocks[#blocks].identifier == 'refs' then
    -- This is the best way to a heading with the right style.
    blocks:insert(#blocks,pandoc.Div(pandoc.Para('Bibliography'),{ ['custom-style'] = 'Bibliography Heading' }))

    -- Adjust the style of the bibliography if it exists.
    local bib = {}
    for _, entry in ipairs(blocks[#blocks].content) do
      entry.attr = { ['custom-style'] = 'Bibliography' }
      bib[#bib+1] = entry
    end
    blocks[#blocks].content = bib
  end

  return pandoc.Pandoc(blocks)
end

-- Microsoft Word styles the footnote reference marker identically in both body 
-- and footnote areas.  To counter this, I've styled "Footnote Reference" as
-- `hidden` in the `.docx` template and, below, manually insert the footnote
-- text and number.  This still leaves one space before the footnote, but I
--cannot adjust that unfortunately.
local function modify_note_contents(n, number)
  n.content[1] = pandoc.Para(
    pandoc.Inlines({
      pandoc.Str(string.format('%i.', number)),
      pandoc.Space(),
      pandoc.Space(),
      table.unpack(n.content[1].content)
    })
  )

  return n
end

if FORMAT == "docx" then
  local note_counter = 0

  function Block(b)
    local content = {}

    for i = 1, #b.content do
      if b.content[i].tag == 'Note' then
        note_counter = note_counter + 1        
        content[#content+1] = pandoc.Superscript(pandoc.Str(note_counter))
        content[#content+1] = modify_note_contents(b.content[i], note_counter)
      else
        content[#content+1] = b.content[i]
      end
    end
    
    b.content = content

    return b
  end
end