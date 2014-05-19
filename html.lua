local Unsafe = require'./unsafe'
local elements = require'./elements'

local table = require'table'
local string = require'string'

local HtmlMeta = {}

local html = {}

--gsub that doesn't that doesn't allow capture references, like %1
local function safe_gsub(str, pattern, str_replace)
	return string.gsub(str,pattern, (string.gsub(str_replace,'%%','%%%%')))
end

--Note: only valid for html attributes that are quoted with double quotes.
--Single quoted, backtick quoted, or unquoted values will leave XSS holes!
local function html_attr_escape(attr, val)
	local replacements = {
		['<']='&lt;',
		['>']='&gt;',
		['"']='&quot;',
		['&']='&amp;'
	}
	local to_replace = '[<>"&]'
	if Unsafe.is(val) then
		local safe_attrs = {align=true, alink=true, alt=true, bgcolor=true, border=true, cellpadding=true, cellspacing=true, class=true, color=true, cols=true, colspan=true, coords=true, dir=true, face=true, height=true, hspace=true, ismap=true, lang=true, marginheight=true, marginwidth=true, multiple=true, nohref=true, noresize=true, noshade=true, nowrap=true, ref=true, rel=true, rev=true, rows=true, rowspan=true, scrolling=true, shape=true, span=true, summary=true, tabindex=true, title=true, usemap=true, valign=true, value=true, vlink=true, vspace=true, width=true} 
		local url_attrs = {href=true, src=true}
		if safe_attrs[attr] then
			return '"'..val.__unsafeString:gsub(to_replace,replacements)..'"'
		elseif url_attrs[attr] then
			error('Must use html.url for url parameters')
		else
			error('Cannot put unsafe content into attribute '..attr)
		end
	else
		if attr == 'style' then
			for k,v in pairs(val) do
				
			end
		else
			return '"'..val:gsub(to_replace,replacements)..'"'
		end
	end
end

--Note: only valid for text content of normal html elements.
local function html_body_escape(str)
	local replacements = {
		['<']='&lt;',
		['>']='&gt;',
		['"']='&quot;',
		['&']='&amp;',
		["'"]='&#x27;',
		['/']='&#x2F;'
	}
	return str:gsub('[<>"&\'/]',replacements)
end

function url_encode(str)
	if Unsafe.is(str) then
		str = str.__unsafeString
	end
	if str then
		str = string.gsub (str, "\n", "\r\n")
		str = string.gsub (str, "([^%w %-%_%.%~])",
			function (c) return string.format ("%%%02X", string.byte(c)) end)
		str = string.gsub (str, " ", "+")
	end
	return str
end


local HtmlElement do
	local HtmlElementM = {}
	function HtmlElement(el)
		local tab = {
			tag = el[1],
			attrs = {},
			content = {},
			_void = not not el.void,
			_noTag = not not el.noTag
		}
		return setmetatable(tab, HtmlElementM), el.global or el[1]
	end

	local function clone(o)
		if type(o) == 'table' then
			local copy = {}
			local m = getmetatable(o)
			for k,v in pairs(o) do
				copy[clone(k)] = clone(v)
			end
			return setmetatable(copy, m)
		else
			return o
		end
	end
	
	function HtmlElementM:__call(content)
		local new = clone(self)
		if type(content) == 'table' then
			local oldlen = #new.content
			for k,v in pairs(content) do
				if type(k) == 'number' then
					new.content[oldlen + k] = v
				else
					new.content[k] = v
				end
			end
		else
			table.insert(new.content, content)
		end
		return new
	end

	function HtmlElementM:__index(attr)
		return function(val)
			local new = clone(self)
			if new.attrs[attr] then
				new.attrs[attr] = new.attrs[attr] .. ' ' .. val
			else
				new.attrs[attr] = val
			end
			return new
		end
	end

	function HtmlElementM:__tostring()
		local innerHtml = {}
		for i=1,#self.content do
			if Unsafe.is(self.content[i]) then
				innerHtml[i] = html_body_escape(self.content[i].__unsafeString)
			elseif type(self.content[i]) == 'string' then
				innerHtml[i] = html_body_escape(self.content[i])
			elseif type(self.content[i]) == 'table' and self.content[i][1] == 'opt' then
				innerHtml[i] = html_body_escape(self.content[self.content[i][2]])
			else
				innerHtml[i] = tostring(self.content[i])
			end
		end
		local attrs = {}
		for k,v in pairs(self.attrs) do
			table.insert(attrs, string.format(' %s=%s', k, html_attr_escape(k,v)))
		end
		local open = ''
		if not self._noTag then
			open = string.format('<%s%s>', self.tag, table.concat(attrs))
		end
		local close = ''
		if not self._void then
			close = string.format("</%s>", self.tag)
		end
		return string.format("%s%s%s", open, table.concat(innerHtml), close)
	end

	function HtmlElementM:__concat(other)
		if self._noTag then
			return self{other}
		elseif other._noTag then
			local ret = clone(other)
			table.insert(ret.content, 1, self)
			return ret
		end
		return html.group{self, other}
	end
end

setmetatable(html,{
	__call = function(self, f)
		return f(self)
	end,
	__index = _ENV
})

function html.opt(name)
	return {'opt', name}
end

html.group = HtmlElement({'',void=true, noTag=true})

function html.loadtemplate(filename, ...)
	return loadfile(filename, 't', html)
end

function html.url(str)
	if str:match('%%q') then
		return str
	else
		return function(tab)
			local query_params = {}
			for k,v in pairs(tab) do
				table.insert(query_params, url_encode(k) .. '=' .. url_encode(v))
				table.insert(query_params, '&')
			end
			--remove the last &
			table.remove(query_params)
			return safe_gsub(str, '%%q','?' .. table.concat(query_params))
		end
	end
end

for i=1,#elements do
	local element, global = HtmlElement(elements[i])
	html[global] = element
end

return html
