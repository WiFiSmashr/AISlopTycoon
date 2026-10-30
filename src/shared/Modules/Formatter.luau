local Formatter = {}

-- Suffixes: "", Thousand, Million, Billion, Trillion, etc.
local SUFFIXES = {
	"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"
}

function Formatter.FormatNumber(num)
	if typeof(num) ~= "number" then
		warn("Input is not a number")
		return tostring(num)
	end

	if num < 1000 then
		return tostring(num)
	end

	local magnitude = math.floor(math.log10(num) / 3) + 1
	local suffix = SUFFIXES[magnitude]

	if not suffix then
		-- Fallback to scientific notation if suffix not defined
		return string.format("%.1e", num)
	end

	local shortNum = num / (10 ^ ((magnitude - 1) * 3))
	local formatted = math.floor(shortNum * 10) / 10

	-- Remove decimal if it's .0
	if formatted == math.floor(formatted) then
		formatted = math.floor(formatted)
	end

	return tostring(formatted) .. suffix
end

function Formatter.formatTime(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60

	if hours > 0 then
		return string.format("%02d:%02d:%02d", hours, minutes, secs)
	elseif minutes > 0 then
		return string.format("%02d:%02d", minutes, secs)
	else
		return string.format("%02ds", secs)
	end
end

return Formatter
