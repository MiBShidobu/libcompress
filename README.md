libcompress By MiBShidobu
===

[GitHub Repository](https://github.com/MiBShidobu/libcompress) &#x02016; [GitHub Page](http://mibshidobu.github.io/libcompress)

## Description: ##
A simple library that provides archiving functionality via FastLZ within Garry's Mod.

## Downloading: ##
This repository is in project format with all the different files and the like, see the [releases](https://github.com/MiBShidobu/libcompress/releases) page for small streamlined releases.

## Dependencies: ##
- [30log](https://github.com/Yonaba/30log)
- [libpack](https://github.com/MiBShidobu/libpack)

## Usage: ##
```lua
-- Compression
require("libcompress")

local test_file_one = file.Read("lua/includes/init.lua", "GAME")
local test_file_two = file.Read("lua/includes/init_menu.lua", "GAME")

local lz_archive = libcompress.LZArchive()
lz_archive:file("init.lua", test_file_one)
lz_archive:file("init_menu.lua", test_file_two)

local compressed_data = lz_archive:get_archive()
file.Write("test_archive.flz.txt", compressed_data)

-- Decompression
require("libcompress")

local compressed_data = file.Read("data/test_archive.flz.txt", "GAME")

local lz_archive = libcompress.LZArchive(compressed_data)
PrintTable(lz_archive:get_files()) --[[
	1	=	init.lua
	2	=	init_menu.lua
]]--

for _, file_name in ipairs(lz_archive:get_files("**.lua")) do
    -- Can filter files too, using ** instead of * keeps it to the same directory level
    print("File:", file_name)
    print(lz_archive:file(file_name)) -- Decompresses and prints the content
end
```

## Credits: ##
[MiBShidobu](https://github.com/mibshidobu) &#x02016; [Steam](http://steamcommunity.com/profiles/76561197967808946) - Project Maintainer