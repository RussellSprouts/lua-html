--attributes.lua

local len(n)
	return function(str)
		return #str >= 1
	end
end

local oneOf(tab)
	local dict = {}
	for i=1,#tab do
		dict[tab[i]] = true
	end
	return function(str)
		return dict[str]
	end
end

local function isTable(val)
	return type(val) == 'table'
end

local function trimUrl(str)
	error("Not yet implemented")
end

local function either(...)
	local t = {...}
	return function(val)
		for i=1,#t do
			if t[i](val) then return true end
		end
	end
end

local function notUnderscore(val)
	return val:sub(1,1) ~= '_'
end

local function isMediaQuery(val)
	error("Not yet implemented")
end

local function isMimeType(type)
	error("Not yet implemented")
end

local function isLanguage(val)
	error("Not yet implemented")
end

local function isSize(val)

end

local function isDateTime(val)
	error"Not yet implemented"
end

local function boolean(name)
	return function(val)
		return val == name or val == '' or type(val) == 'boolean'
	end
end

local function isInteger(val)
	return type(val) == 'number' and math.floor(n) == n 
end

local function isNumber(val)
	return type(val) == 'number'
end

local function positiveInt(val)
	return isInteger(val) and val > 0
end

local function nonNegativeInt(val)
	return isInteger(val) and val >= 0
end

local function hashReference(val)
	return val:sub(1,1) == '#'
end

local function isFileType(val)
	return val:sub(1,1) == '.'
end

local function noSpaces(val)
	return not val:match("%s")
end

local function noNewline(val)
	return not val:match"[\n\r]"
end

local global_attributes = {
	"accesskey",
	{"class",multi=' '},
	"contenteditable",
	{"dir", valid=oneOf{'ltr','rtl','auto'}},
	"draggable",
	"dropzone",
	"hidden",
	--should also be unique
	{'id', valid=len(1)},
	{"lang", valid=isLanguage},
	"spellcheck",
	{"style", valid=isTable, multi=';'},
	"tabindex",
	"title",
	"translate",
	"role",
	"aria-*",
	"data-*"
}

local global_events = {
	"onabort",
	"onblur",
	"oncancel",
	"oncanplay",
	"oncanplaythrough",
	"onchange",
	"onclick",
	"onclose",
	"oncuechange",
	"ondblclick",
	"ondrag",
	"ondragend",
	"ondragenter",
	"ondragexit",
	"ondragleave",
	"ondragover",
	"ondragstart",
	"ondrop",
	"ondurationchange",
	"onemptied",
	"onended",
	"onerror",
	"onfocus",
	"oninput",
	"oninvalid",
	"onkeydown",
	"onkeypress",
	"onkeyup",
	"onload",
	"onloadeddata",
	"onloadedmetadata",
	"onloadstart",
	"onmousedown",
	"onmouseenter",
	"onmouseleave",
	"onmousemove",
	"onmouseout",
	"onmouseover",
	"onmouseup",
	"onmousewheel",
	"onpause",
	"onplay",
	"onplaying",
	"onprogress",
	"onratechange",
	"onreset",
	"onresize",
	"onscroll",
	"onseeked",
	"onseeking",
	"onselect",
	"onshow",
	"onstalled",
	"onsubmit",
	"onsuspend",
	"ontimeupdate",
	"ontoggle",
	"onvolumechange",
	"onwaiting"
}

local other_events = {'onafterprint','onbeforeprint','onbeforeunload','onhashchange','onmessage','onoffline','ononline','onpagehide','onpageshow','onpopstate','onstorage','onunload'}

local other = {
	{"manifest", valid=trimUrl},
	{"href", valid=trimUrl},
	{"target", 'formtarget', valid=either(oneOf{'_blank','_self','_parent','_top'},notUnderscore)},
	{"crossorigin", valid=oneOf{'anonymous', 'use-credentials'}},
	{"rel", multi=' ', valid=oneOf{"alternate","author","bookmark","help","icon","license","next","nofollow","noreferrer","prefetch","prev","search","stylesheet","tag"}},
	{"media", valid=isMediaQuery},
	{"hreflang", valid=isLanguage},
	{'srclang', valid=isLanguage},
	{"type", valid=isMimeType},
	{"sizes", multi=' ', valid=isSize},
	{"http-equiv", valid=oneOf{'content-type','default-style','refresh'}}.
	{"charset", valid=oneOf{"utf-8"}},
	{"reversed", boolean=true}
	{"start",valid=isInteger},
	{"ol/type", valid=oneOf{'l','a','A','i','I'}},
	{"li/value", valid=isInteger},
	{"download", boolean='maybe'},
	{"cite", valid=trimUrl},
	{"value"},
	{"datetime", valid=isDateTime},
	{"alt", valid=len(1)},
	{"usemap", valid=hashReference},
	{"ismap", boolean=true},
	{"width",valid=nonNegativeInt},
	{"height",valid=nonNegativeInt},
	{"src",valid=trimUrl},
	{"srcdoc"},
	{"sandbox", valid=oneOf{'allow-forms','allow-pointer-lock','allow-popups','allow-same-origin','allow-scripts','allow-top-navigation'}},
	{'data', valid=trimUrl},
	{"typemustmatch", boolean=true},
	{"object/name", valid=notUnderscore},
	{"name", valid=len(1)},
	{"form", valid=len(1)},
	{"poster", valid=trimUrl},
	{"preload", valid=oneOf{'none','metadata','auto'}},
	{'autoplay', boolean=true},
	{'mediagroup', valid=len(1)},
	{'loop', boolean=true},
	{'muted',boolean=true},
	{'controls',boolean=true},
	{'kind',valid=oneOf{'subtitles','captions','descriptions','chapters','metadata'}},
	{'label',valid=len(1)},
	{'default', boolean=true},
	{'map/name'},
	{'coords',multi=',',valid=isInteger},
	{'shape', valid=oneOf{'circle','default','poly','rect'}},
	{'span', valid=positiveInt},
	{'colspan',valid=nonNegativeInt},
	{'rowspan',valid=nonNegativeInt},
	{'headers', multi=' '},
	{'scope', valid=oneOf{'row','col','rowgroup','colgroup'}},
	{'abbr'},
	{'accept-charset', valid=oneOf{'utf-8'}},
	{'action', 'formaction', valid=trimUrl},
	{'autocomplete', boolean='on/off', valid=oneOf{'on','off'}},
	{'enctype', 'formenctype', valid=oneOf{'application/x-www-form-urlencoded','multipart/form-data','text/plain'}},
	{'form/name', valid=len(1)},
	{'novalidate','formnovalidate', boolean=true},
	{'accept',multi=',',valid=either(oneOf{'image/*','audio/*','video/*'},isMimeType,isFileType)},
	{'checked','disabled','autofocus','multiple','readonly','required','selected', boolean=true},
	{'dirname',valid=len(1)},
	{'method','formmethod', valid=oneOf{'GET','POST'}},
	{'list',valid=len(1)},
	{'min','max'},
	{'maxlength', 'minlength','cols','rows' valid=positiveInt},
	{'pattern'},
	{'placeholder', valid=noNewline},
	{'size',valid=nonNegativeInt},
	{'step',valid=either(oneOf{'any'},isNumber)},
	{'input/type', valid=oneOf{"hidden","text","search","tel","url","email","password","date","time","number","range","color","checkbox","radio","file","submit","image","reset","button",}}
	{'button/type',valid=oneOf{"submit",'reset','button'}},
	{'wrap',valid=oneOf{'soft,hard'}},
	{'keytype',valid=oneOf{'rsa'}},
	{'challenge'},
	{'for',multi=' ',valid=len(1)},
	{'meter/min','meter/max','meter/low','meter/high','meter/optimum', valid=isNumber},
	{'async','defer', boolean=true}.
}
