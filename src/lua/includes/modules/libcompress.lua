-- lua/includes/modules/libcompress.lua

-- =============================================================================
-- >>> IMPORTS
-- =============================================================================
-- External
require("30log")

-- Internal
require("libpack.format")

-- =============================================================================
-- >>> UTILITY FUNCTIONS
-- =============================================================================
-- Source: wildfiregames
-- http://svn.wildfiregames.com/public/ps/trunk/build/premake/premake4/src/base/path.lua
local function glob_pattern(match_pattern)
	-- Converts from a simple wildcard syntax, where * is 'match any' and ** is 'match recursive', to the corresponding Lua pattern
	match_pattern = match_pattern:gsub("([%+%.%-%^%$%(%)%%])", "%%%1")

	match_pattern = match_pattern:gsub("%*%*", "\001")
	match_pattern = match_pattern:gsub("%*", "\002")

	match_pattern = match_pattern:gsub("\001", ".*")
	match_pattern = match_pattern:gsub("\002", "[^/]*")
	
	return match_pattern
end

local function has_match(match_pattern, match_string)
	-- Matches the Glob-like pattern to the string
	if string.match(match_string, glob_pattern(match_pattern)) then
		return true
	end

	return false
end

-- =============================================================================
-- >>> LIBRARY CLASSES
-- =============================================================================
local LZArchive = class("LZArchive")

function LZArchive:init(compressed_data)
	-- Constructor for the LZArchive class
	self.file_cache = {}
	if compressed_data then
		local archive_length = libpack.format.unpack("<L", compressed_data)

		compressed_data = string.sub(compressed_data, 5)
		while archive_length > 0 do
			local file_path	= libpack.format.unpack("<A", compressed_data)
			compressed_data	= string.sub(compressed_data, #file_path + 5)

			local file_content	= libpack.format.unpack("<A", compressed_data)
			compressed_data		= string.sub(compressed_data, #file_content + 5)

			table.insert(self.file_cache, {
				path	= util.Decompress(file_path),
				content	= util.Decompress(file_content)
			})

			archive_length = archive_length - 1
		end
	end
end

function LZArchive:file(file_path, file_content)
	-- Returns or sets a file's content from the LZArchive
	local file_data = nil
	for _, file_info in ipairs(self.file_cache) do
		if file_info.path == file_path then
			file_data = file_info
		end
	end

	if file_content then
		if file_data then
			file_data.content = file_content

		else
			table.insert(self.file_cache, {
				path	= file_path,
				content	= file_content
			})
		end

	elseif file_data then
		return file_data.content
	end
end

function LZArchive:get_files(filter_pattern)
	-- Returns the file names matched to the option filter pattern
	local file_list = {}

	filter_pattern = filter_pattern or "*"
	for _, file_info in ipairs(self.file_cache) do
		if has_match(filter_pattern, file_info.path) then
			table.insert(file_list, file_info.path)
		end
	end

	table.sort(file_list)
	return file_list
end

function LZArchive:get_archive()
	-- Compresses the added files and returns the completed archive
	local archive_content = libpack.format.pack("<L", #self.file_cache)
	for _, file_info in ipairs(self.file_cache) do
		local path_packed		= libpack.format.pack("<A", util.Compress(file_info.path))
		local content_packed	= libpack.format.pack("<A", util.Compress(file_info.content))

		archive_content = archive_content..path_packed..content_packed
	end

	return archive_content
end

-- =============================================================================
-- >>> LIBRARY DEFINITIONS
-- =============================================================================
-- namespace
libcompress = libcompress or {}

-- class
libcompress.LZArchive = libcompress.LZArchive or LZArchive