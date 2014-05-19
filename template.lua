local name, value = ...

local Article = div {
	opt'title'
}

return html {
	head {
		title {"Hi " .. name},
		meta.charset'utf-8'
	},
	body {
		Article{title='hi'}
	}
}