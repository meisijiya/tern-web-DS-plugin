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
local CHAT_HOST = "chat." .. SITE

-- The action the segment's click runs, and the only place the name is built.
local OPEN_ACTION = ("plugin.%s.open"):format(PLUGIN)

local function host_of(url)
	if type(url) ~= "string" then
		return nil
	end
	local host = string.match(url, "^%a[%w+.-]*://([^/?#]+)")
	if host == nil then
		return nil
	end
	host = string.gsub(host, "^.*@", "")
	host = string.gsub(host, ":%d+$", "")
	return string.lower(host)
end

local function is_site(url)
	local host = host_of(url)
	return host ~= nil and (host == SITE or string.sub(host, -#SITE - 1) == "." .. SITE)
end

local function is_chat(url)
	return host_of(url) == CHAT_HOST
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
-- rather than merely focused — and shown, because a block can be parked or in
-- another tab: claiming the click means the click has to have a visible answer.
local function navigate(cx, pane, url)
	cx.browser:call({ op = "goto", block = pane, url = url }):next(function(result, err, nextCx)
		local why = err ~= nil and tostring(err) or refuse(result)
		if why ~= nil then
			nextCx:toast("error", "WebDS: 链接没能打开", why)
			return
		end
		nextCx.layout:focus(pane)
	end)
end

-- The page the user is looking at: its pane id and address, or nothing. A
-- block that failed to load keeps the address it wanted and would show a dead
-- page, so it is not a match — the pane record does not carry that failure,
-- only the block read does. Chat pages win over other pages of the site: the
-- composer is the point.
local function chat_pane(cx)
	local first, first_url
	for _, pane in ipairs(cx.session:panes()) do
		if pane.kind == "browser" and is_site(pane.url) then
			local read = cx.session:read(pane.pane)
			if type(read) == "table" and read.kind == "browser" and read.error == nil then
				if is_chat(pane.url) then
					return pane.pane, pane.url
				end
				first = first or pane.pane
				first_url = first_url or pane.url
			end
		end
	end
	return first, first_url
end

-- Opens the page beside the focused block, or brings the open one back into
-- sight. A block that a link route left on another page of the site is steered
-- back to the chat: the entry point promises the composer, not the site.
local function show(cx, url)
	local pane, current = chat_pane(cx)
	if pane == nil then
		cx:open(url, "beside")
	elseif is_chat(current) then
		cx.layout:focus(pane)
	else
		navigate(cx, pane, url)
	end
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
