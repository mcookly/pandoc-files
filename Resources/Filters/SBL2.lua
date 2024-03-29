local function blockify(el)
	if pandoc.utils.type(el) == 'Inlines' then
		return pandoc.Para(pandoc.Inlines(el))
	end

	return el
end

function Pandoc(p)
	-- Citeproc needs to be run first so it has all the metadata.
	p.meta['link-bibliography'] = false
	local doc = pandoc.utils.citeproc(p)

	local blocks = pandoc.List:new()

	if p.meta.institution then
		blocks:insert(pandoc.Div(
			blockify(p.meta.institution),
			{ ['custom-style'] = 'Institution' }
		))
	end

	if p.meta.title then
		blocks:insert(pandoc.Div(
			blockify(p.meta.title),
			{ ['custom-style'] = 'Title' }
		))
	end

	if p.meta.subtitle then
		blocks:insert(pandoc.Div(
			blockify(p.meta.subtitle),
			{ ['custom-style'] = 'Title' }
		))
	end

	if p.meta.submission then
		blocks:insert(pandoc.Div(
			blockify(p.meta.submission),
			{ ['custom-style'] = 'Submission' }
		))
	end

	if p.meta.author then
		blocks:insert(pandoc.Div(
			pandoc.Blocks({
				pandoc.Para(pandoc.Str('By')),
				blockify(p.meta.author),
			}),
			{ ['custom-style'] = 'Author' }
		))
	end

	-- There will always be a date.
	local date
	if p.meta.date then
		local year, month, day = pandoc.utils.normalize_date(
			pandoc.utils.stringify(p.meta.date)
		):match([[(%d%d%d%d)%-(%d%d)%-(%d%d)]])
		date = os.time({ year = year, month = month, day = day })
	else
		date = os.time()
	end

	blocks:insert(pandoc.Div(
		pandoc.Para(os.date('%B %e, %Y', date)),
		{ ['custom-style'] = 'Date' }
	))

	-- Before adding the document, we need to adjust H6 to be an inline heading.
	for i = #doc.blocks - 1, 1, -1 do
		if doc.blocks[i].tag == 'Header' and doc.blocks[i].level == 6 then
			local inline_para = doc.blocks[i].content

			-- Add punctuation if needed.
			if not inline_para[#inline_para].text:match([[[%.%:%;%?%!]$]]) then
				inline_para[#inline_para] = pandoc.Str(inline_para[#inline_para].text .. '.')
			end

			-- Format with emphasis per CMOS 17 guidelines.
			inline_para = { pandoc.Emph(pandoc.Inlines(inline_para)) }

			inline_para[#inline_para + 1] = pandoc.Space()

			-- Append paragraph content
			for j = 1, #doc.blocks[i + 1].content do
				inline_para[#inline_para + 1] = doc.blocks[i + 1].content[j]
			end

			doc.blocks[i + 1].content = inline_para

			-- Remove H6.
			doc.blocks:remove(i)
		end
	end

	blocks:extend(doc.blocks)

	-- For papers with no citations, no bibliography editing is needed.
	if blocks[#blocks].identifier == 'refs' then
		-- This is the best way to a heading with the right style.
		blocks:insert(#blocks, pandoc.Div(pandoc.Para('Bibliography'), { ['custom-style'] = 'Bibliography Heading' }))

		-- Adjust the style of the bibliography if it exists.
		local bib = {}
		for _, entry in ipairs(blocks[#blocks].content) do
			entry.attr = { ['custom-style'] = 'Bibliography' }
			bib[#bib + 1] = entry
		end
		blocks[#blocks].content = bib
	end

	return pandoc.Pandoc(blocks)
end

function Inlines(i)
	for j = #i - 1, 1, -1 do
		-- Convert en-dashes to em-dashes per SBL/CMOS 17 style.
		if i[j].tag == 'Str' then
			if i[j].text == '–' and i[j - 1].tag == 'Space' and i[j + 1].tag == 'Space' then
				i[j].text = '—'
				i:remove(j + 1)
				i:remove(j - 1)
			end
		end
	end

	return i
end

function Str(s)
	-- Convert hyphen between numbers to an en-dash.
	if s.text:match('%d+-%d+') then
		s.text = s.text:gsub('-', '–')
	end

	return s
end
