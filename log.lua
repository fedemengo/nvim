local log = {
	_version = "0.1.0",
	caller = false,
	usecolor = true,
	outfile = nil,
	level = "trace",
}

local modes = {
	{ name = "trace", color = "\27[34m" },
	{ name = "debug", color = "\27[36m" },
	{ name = "info", color = "\27[32m" },
	{ name = "warn", color = "\27[33m" },
	{ name = "error", color = "\27[31m" },
	{ name = "fatal", color = "\27[35m" },
}

local levels = {}
for i, v in ipairs(modes) do
	levels[v.name] = i
end

local round = function(x, increment)
	increment = increment or 1
	x = x / increment
	return (x > 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)) * increment
end

local _tostring = tostring

function vtostring(...)
	local t = {}
	for i = 1, select("#", ...) do
		local x = select(i, ...)
		if type(x) == "number" then
			x = round(x, 0.01)
		elseif type(x) == "table" then
			x = tabletostring(x)
		end
		t[#t + 1] = _tostring(x)
	end
	return table.concat(t, " ")
end

function tabletostring(table)
	local str = ""
	for k, v in pairs(table) do
		if type(v) == "table" then
			str = string.format('%s"%s": %s%, ', str, vtostring(k), tabletostring(v))
		else
			str = string.format('%s"%s": "%s", ', str, vtostring(k), vtostring(v))
		end
	end
	str = str:sub(1, -3)
	return string.format("{%s}", str)
end

for i, x in ipairs(modes) do
	local nameupper = x.name:upper()
	log[x.name] = function(...)
		if i < levels[log.level] then
			return
		end

		local msg = vtostring(...)
		local info = debug.getinfo(2, "Sl")
		local short = info.short_src
		local home = os.getenv("HOME")
		if not home then
			home = "~"
		end

		short = short:gsub(home .. "/.dotfiles/.config/nvim/", "nvim/")
		short = short:gsub(home .. "/.config/nvim/", "nvim/")
		short = short:gsub(home, "~")

		local lineinfo = short .. ":" .. info.currentline

		if log.outfile then
			local fp = io.open(log.outfile, "a")
			local str = string.format(
				"%s[%-6s%s]%s %s %s\n",
				log.usecolor and x.color or "",
				nameupper,
				os.date("%H:%M:%S"),
				log.usecolor and "\27[0m" or "",
				log.caller and lineinfo or "",
				msg
			)

			if fp then
				fp:write(str)
				fp:close()
			end
		end
		if x.name == "fatal" then
			os.exit(1)
		end
	end
end

log["withcaller"] = function(b)
	log.caller = b
end

log["tofile"] = function(filename)
	log.outfile = filename
end

log["setup"] = function(opts)
	opts = opts or {}
	log.caller = opts.caller or log.caller
	log.usecolor = opts.usecolor or log.usecolor
	log.outfile = opts.outfile or log.outfile
	log.level = opts.level or log.level
	return log
end

return log
