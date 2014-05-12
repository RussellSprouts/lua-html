local h = require'html'

local function test(msg, expected, actual)
	assert(expected==tostring(actual), string.format("Failed test: %s:\n  expected: %s\n  actual: %s", msg, expected, actual))
end

test("Empty element", "<span></span>", h.span)

local voids = {'area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input', 'keygen', 'link', 'meta', 'param', 'source', 'track', 'wbr'}
for i=1,#voids do
	test("Void elements unclosed", "<"..voids[i]..">", h[voids[i]])
end

test("Class name",'<a class="c"></a>', h.a.class'c')

test("No mutation on attrs", '<a id="test"></a><a></a>',h(function(_ENV)
	local custom = a.id'test'
	return custom .. a
end))

test("No mutation on content", '<a>content1</a><a>content2</a>', h(function(_ENV)
	local content1 = a'content1'
	local content2 = a'content2'
	return content1 .. content2
end))

test('add content to existing', '<a class="test">c1</a><a class="test">c2</a>', h(function(_ENV)
	local custom = a.class'test'
	return custom'c1' .. custom'c2'
end))

test('add attrs to existing', '<a class="test">c1</a><a>c1</a>', h(function(_ENV)
	local custom = a'c1'
	return custom.class'test' .. custom
end))

test('call appends content', '<a>c1c2</a>', h(function(_ENV)
	return a 'c1' 'c2'
end))

test('content as a table', '<a>abc</a>',h(function(_ENV)
	return a {'a','b','c'}
end))

test('multiple concats', '<br><img><area>', h.br .. h.img .. h.area)

test('concat with string', '<p>Hello <strong>there</strong>!</p>', h.p{"Hello " .. h.strong"there" .. "!"})