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

  -- This is the best way to a heading with the right style.
  blocks:insert(#blocks,pandoc.Div(pandoc.Para('Bibliography'),{ ['custom-style'] = 'Bibliography Heading' }))

  -- Adjust the style of the bibliography
  local bib = {}
  for _, entry in ipairs(blocks[#blocks].content) do
    entry.attr = { ['custom-style'] = 'Bibliography 1' }
    bib[#bib+1] = entry
  end
  blocks[#blocks].content = bib

  return pandoc.Pandoc(blocks)
end