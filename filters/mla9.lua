local footnotes = {}
local footnoteNum = 0

-- Strip common metadata (for DOCX and automatic --standalone formats)
local function stripMeta(meta)
    meta.title = nil
    meta.subtitle = nil
    meta.author = nil
    meta.professor = nil
    meta.date = nil
    return nil
end

-- Insert pagebreaks for Notes section and Works Cited section
-- From pandoc/lua-filters
local function insertPageBreak(format)
    local pagebreak = {
        asciidoc = '<<<\n\n',
        context = '\\page',
        epub = '<p style="page-break-after: always;"> </p>',
        html = '<div style="page-break-after: always;"></div>',
        latex = '\\newpage{}',
        ms = '.bp',
        ooxml = '<w:p><w:r><w:br w:type="page"/></w:r></w:p>',
        odt = '<text:p text:style-name="Pagebreak"/>'
      }

      if format:match 'asciidoc' then
        return pandoc.RawBlock('asciidoc', pagebreak.asciidoc)
      elseif format:match 'context' then
        return pandoc.RawBlock('context', pagebreak.context)
      elseif format:match 'docx' then
        return pandoc.RawBlock('openxml', pagebreak.ooxml)
      elseif format:match 'epub' then
        return pandoc.RawBlock('html', pagebreak.epub)
      elseif format:match 'html.*' then
        return pandoc.RawBlock('html', pagebreak.html)
      elseif format:match 'latex' then
        return pandoc.RawBlock('tex', pagebreak.latex)
      elseif format:match 'ms' then
        return pandoc.RawBlock('ms', pagebreak.ms)
      elseif format:match 'odt' then
        return pandoc.RawBlock('opendocument', pagebreak.odt)
      else
        -- fall back to insert a form feed character
        return pandoc.Para{ pandoc.Str '\f' }
      end
end

-- Insert footnotes
local function insertEndnotes(content, pos)
  -- content: MUST be a table
  -- pos: 'before' --> insert endnotes before content. 'after' --> vice versa.
  if not next(footnotes) then
    -- Don't do anything if footnotes are already inserted or don't exist.
    return content
  end

  local notes = pandoc.Div({ insertPageBreak(FORMAT), pandoc.Para{ pandoc.Str('Notes') }, table.unpack(footnotes) })
  notes.attr =  {['custom-style'] = 'Centered Text'}
  footnotes = {} -- All done!

  if pos:match 'before' then
    return { notes, table.unpack(content) }
  elseif pos:match 'after' then
    return { table.unpack(content), notes }
  else
    return content -- Avoid errors and nil issues.
  end
end

-- Find all footnotes, add to a table, and replace with a superscripted number.
function Note(note)
    footnoteNum = footnoteNum + 1 -- This might be a bit of a hack, but it works.
    -- This unpacks the Para block, adds the number, and repacks before adding to the footnotes table.
    -- It's wrapped in Div to apply custom styling for DOCX and ODT formats
    local fn = pandoc.Div(pandoc.Para { pandoc.Str(footnoteNum .. '. '), table.unpack(note.content[1].content) })
    fn.attributes['custom-style'] = 'Endnote Text'
    footnotes[footnoteNum] = fn
    note = pandoc.Superscript { pandoc.Str(footnoteNum) }
    return note
end

function Block(b)
    if b.identifier == 'bibliography' then -- Header of Works Cited section
        -- Replacing the Header block with Para block wrapped in a Div allows for custom styling.
        local bib = pandoc.Div(pandoc.Para{ pandoc.Str('Works Cited') })
        bib.identifier = b.identifier -- Load old attributes from the header
        bib.attributes['custom-style'] = 'Centered Text'

        -- Insert notes before Works Cited in MLA 9 format.
        return insertEndnotes({insertPageBreak(FORMAT), bib}, 'before')

    elseif b.identifier == 'refs' then -- Actual references in Works Cited section
        b.attributes['custom-style'] = 'Bibliography'
        return b

    else
        return b
    end
end

-- Document call
function Pandoc(doc)
    -- Add MLA header info
    table.insert(doc.blocks, 1, pandoc.Para { table.unpack(doc.meta.author) }) -- Author
    table.insert(doc.blocks, 2, pandoc.Para { table.unpack(doc.meta.professor) }) -- Professor
    table.insert(doc.blocks, 3, pandoc.Para { table.unpack(doc.meta.course) }) -- Course
    table.insert(doc.blocks, 4, pandoc.Para { table.unpack(doc.meta.date) }) -- Date

    -- Add title and subtitle
    local title = {table.unpack(doc.meta.title)}
    if doc.meta.subtitle then
        title[#title+1] = pandoc.Str(':')
        title = pandoc.Div(pandoc.Para { table.unpack(title) }, {['custom-style'] = 'Centered Text'})
        -- Insert at position 5 since the title will be inserted before this at pos. 5 as well.
        local subtitle = pandoc.Div(pandoc.Para { table.unpack(doc.meta.subtitle) }, {['custom-style'] = 'Centered Text'})
        table.insert(doc.blocks, 5, subtitle)
    end
    table.insert(doc.blocks, 5, title)

    -- Insert footnotes if they're not inserted yet (i.e., no bibliography)
    doc.blocks = insertEndnotes(doc.blocks, 'after')

    -- Strip META info so that DOCX does not insert it
    if FORMAT:match 'docx' then
        stripMeta(doc.meta)
    end

    return doc
end