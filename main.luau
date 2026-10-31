-- WebDS — chat.deepseek.com in a Tern browser block.
--
-- One palette command and one status segment open (or reveal) the page beside
-- the focused block. Nothing here stores a login: the page lives in the
-- WebView2 website data store every Tern browser block shares, so a sign-in
-- made once survives restarts on its own.
--
-- The other half is a link route: a click on a link of the site outside the
-- DeepSeek block belongs in that block, not in a second copy of the page.

local PLUGIN = "deepseek-web"
local CHAT_URL = "https://chat.deepseek.com/"
local SITE = "deepseek.com"

-- The action the segment's click runs, and the only place the name is built.
local OPEN_ACTION = ("plugin.%s.open"):format(PLUGIN)

local function is_site(url)
	if type(url) ~= "string" then
		return false
	end
	local host = string.match(url, "^%a[%w+.-]*://([^/?#]+)")
	if host == nil then
		return false
	end
	host = string.lower((string.gsub((string.gsub(host, "^.*@", "")), ":%d+$", "")))
	return host == SITE or string.sub(host, -#SITE - 1) == "." .. SITE
end

-- The page the user is looking at, if any. A block that failed to load carries
-- the address it wanted and would show a dead page, so it is not a match.
-- Chat pages win over other pages of the site: the composer is the point.
local function chat_pane(cx)
	local first
	for _, pane in ipairs(cx.session:panes()) do
		if pane.kind == "browser" and is_site(pane.url) and pane.error == nil then
			if string.find(pane.url, "//chat.", 1, true) ~= nil then
				return pane.pane
			end
			first = first or pane.pane
		end
	end
	return first
end

local function refuse(result)
	if type(result) ~= "table" then
		return "the browser answered nothing"
	end
	if result.error ~= nil then
		return ("%s: %s"):format(tostring(result.error.kind), tostring(result.error.message))
	end
	return nil
end

-- A link arrives with an address of its own, so an open block is steered there
-- rather than merely focused.
local function navigate(cx, pane, url)
	cx.browser:call({ op = "goto", block = pane, url = url }):next(function(result, err, nextCx)
		local why = err ~= nil and tostring(err) or refuse(result)
		if why ~= nil then
			nextCx:toast("error", "WebDS: 链接没能打开", why)
		end
	end)
end

-- Opens the page beside the focused block, or brings the open one back into
-- sight. `how` keeps the split: the user asked for beside, and every path here
-- agrees with the first one opened.
local function show(cx, url)
	local pane = chat_pane(cx)
	if pane ~= nil then
		cx.layout:focus(pane)
		return pane
	end
	cx:open(url, "beside")
	return nil
end

-- Registered at entry load, not under tern.on("window_start"): window_start is
-- dispatched before this plugin's window half has loaded, so a handler
-- registered there never runs and neither the segment nor the commands appear.
tern.chrome.status(function()
	return { {
		text = "WebDS",
		icon = "md-web",
		tone = "muted",
		command = OPEN_ACTION,
	} }
end)

tern.command({
	id = "open",
	title = "WebDS: Open DeepSeek",
	icon = "md-web",
	run = function(cx)
		show(cx, CHAT_URL)
	end,
})

-- A click on a site link outside the DeepSeek block belongs in that block. A
-- click inside it is left alone: the page navigating itself is what the user
-- asked for.
tern.route.link(function(link, cx)
	if not is_site(link.url) then
		return nil
	end
	local read = cx.session:read(link.pane)
	if type(read) == "table" and read.kind == "browser" and is_site(read.url) then
		return nil
	end
	local pane = chat_pane(cx)
	if pane ~= nil then
		navigate(cx, pane, link.url)
	else
		cx:open(link.url, "beside")
	end
	return { handled = true }
end)
