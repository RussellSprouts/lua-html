
local HtmlMeta = {}


local elements = require'elements'

local html = {}

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
			for i=1,#content do
				table.insert(new.content, content[i])
			end
		else
			table.insert(new.content, content)
		end
		return new
	end

	function HtmlElementM:__index(attr)
		return function(val)
			local new = clone(self)
			new.attrs[attr] = val
			return new
		end
	end

	function HtmlElementM:__tostring()
		local innerHtml = {}
		for i=1,#self.content do
			innerHtml[i] = tostring(self.content[i])
		end
		local attrs = {}
		for k,v in pairs(self.attrs) do
			table.insert(attrs, string.format(" %s=%q", k, v))
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

html.group = HtmlElement({'',void=true, noTag=true})

for i=1,#elements do
	local element, global = HtmlElement(elements[i])
	html[global] = element
end

return html
