
local HtmlMeta = {}


local elements = require'elements'

local HtmlElement do
	local HtmlElementM = {}
	function HtmlElement(el)
		local tab = {
			tag = el.el or el[1],
			global = el[1],
			attrs = {},
			content = {},
			void = el[2] == 'void'
		}
		return setmetatable(tab, HtmlElementM)
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
		local close = ''
		if not self.void then
			close = string.format("</%s>", self.tag)
		end
		return string.format("<%s%s>%s%s", self.tag, table.concat(attrs), table.concat(innerHtml), close)
	end

	function HtmlElementM:__concat(other)
		return tostring(self) .. tostring(other)
	end
end

local html = {}
setmetatable(html,{
	__call = function(self, f)
		return f(self)
	end,
	__index = _ENV
})

for i=1,#elements do
	local element = HtmlElement(elements[i])
	html[element.global] = element
end

return html
