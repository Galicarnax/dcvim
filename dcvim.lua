local param = {...}

-- script accepts four params: the key, %dc_config_path%, path of current filer/dir and path of the active panel
if #param < 4 then
    DC.LogWrite("dcvim script called with less than 3 parameters", 2, true, false)
    return
end

local key = param[1]
local delim = SysUtils.PathDelim
local file_mode = param[2] .. delim .. "dcvim" .. delim .. "vars" .. delim .. "mode"

-- <ESC> hit: go to normal mode
if key == "esc" then
    io.open(file_mode, "w"):close()
    return
end

function emulateKey(ekey, count)
    -- is there a better way to determine from the script in which OS type we are?
    if delim == "/" then
        local tkey = ekey
        -- xdotool uses quirky names for PageUp and PageDown
        if ekey == "PageUp" then tkey = "Page_Up" end
        if ekey == "PageDown" then tkey = "Page_Down" end
        local str = tkey
        for i = 2, count, 1 do
            str = str .. " " .. tkey
        end
        os.execute("xdotool key --delay 0 " .. str)
    else
        if count > 1 then
            DC.ExecuteCommand("cm_ExecuteToolBarItem", "ToolItemID={" .. ekey .. "-" .. count .. "-Key-Emulator}")
        else
            DC.ExecuteCommand("cm_ExecuteToolBarItem", "ToolItemID={" .. ekey .. "-Key-Emulator}")
        end
    end
end

local mode = nil
local mfile = io.open(file_mode, "r")
if mfile ~= nil then
    mode = mfile:read("*l")
    mfile:close()
end

if mode == nil or mode == "" then
    
    if key == "f" or key == "g" or key == "s" or key == "d"
        or key == "y"or key == "p" or key == "v" or key == "m" or key == "n"
        or key == "'" or key == "`" or key == "c" or key == "D" or key == "r" then
        
        mfile = io.open(file_mode, "w")
        mfile:write(key)
        mfile:close()
        
        if key == "f" then
            local file_find_sym = param[2] .. delim .. "dcvim" .. delim .. "vars" .. delim .. "find_sym"
            local ffile = io.open(file_find_sym, "w")
            ffile:write("")
            ffile:close()
        end
        
    elseif key == "j" then
        DC.ExecuteCommand("cm_GoToNextEntry")
        
    elseif key == "h" then
        DC.ExecuteCommand("cm_ChangeDirToParent")
        
    elseif key == "k" then
        DC.ExecuteCommand("cm_GoToPrevEntry")
        
    elseif key == "[" then
        for cc = 1, 5 do
            DC.ExecuteCommand("cm_GoToPrevEntry")
        end
        
    elseif key == "]" then
        for cc = 1, 5 do
            DC.ExecuteCommand("cm_GoToNextEntry")
        end
        
    elseif key == "u" then
        DC.ExecuteCommand("cm_Exchange")
        
    elseif key == ":" then
        DC.ExecuteCommand("cm_FocusCmdLine")
        
    elseif key == "H" then
        DC.ExecuteCommand("cm_ViewHistoryPrev")
        
    elseif key == "L" then
        DC.ExecuteCommand("cm_ViewHistoryNext")
        
    elseif key == "/" then
        DC.ExecuteCommand("cm_QuickSearch")
        
    elseif key == "G" then
        DC.ExecuteCommand("cm_GoToLastEntry")
        
    elseif key == "l" then
        local fileattr = SysUtils.FileGetAttr(param[3])
        -- apply Open command only if directory is under cursor
        if fileattr > 0 then
            if math.floor(fileattr / 0x00000010) % 2 ~= 0 then
                DC.ExecuteCommand("cm_Open")
            else
                -- allow enter archives. Scan doublecmd.xml for matching extensions between ArchiveExt tags (an ad-hoc solution)
                local ext = SysUtils.ExtractFileExt(param[3])
                if ext == nil or ext == "" then return end
                local file_dc_config = param[2] .. delim .. "doublecmd.xml"
                local fp = io.open(file_dc_config, "r")
                if fp ~= nil then
                    -- escape minus and plus symbols which may occur in extension (think '.sublime-package')
                    ext = ext:sub(2):gsub("([%-%+])", "%%%1")
                    for line in fp:lines() do
                        if line:match("<ArchiveExt>" .. ext .. "</ArchiveExt>") then
                            DC.ExecuteCommand("cm_Open")
                            break
                        end
                    end
                    fp:close()
                end
            end
        else
            -- something different - probably we are within archive or a network connection
            -- in this case it seems there is no way to distinguish between directories and files using DC commands,
            -- so just trigger Open action for any entry
            DC.ExecuteCommand("cm_Open")
        end
        
    elseif key == "," then
        local file_find_sym = param[2] .. delim .. "dcvim" .. delim .. "vars" .. delim .. "find_sym"
        local ffile = io.open(file_find_sym, "r")
        if ffile == nil then return end
        local prefix = ffile:read("*l")
        ffile:close()
        if prefix == nil or prefix == "" then return end
        DC.ExecuteCommand("cm_QuickSearch", "search=on", "direction=next", "files=on", "directories=off", "text=" .. prefix)
        DC.ExecuteCommand("cm_QuickSearch", "search=off")
        
    elseif key == ";" then
        local file_find_sym = param[2] .. delim .. "dcvim" .. delim .. "vars" .. delim .. "find_sym"
        local ffile = io.open(file_find_sym, "r")
        if ffile == nil then return end
        local prefix = ffile:read("*l")
        ffile:close()
        if prefix == nil or prefix == "" then return end
        DC.ExecuteCommand("cm_QuickSearch", "search=on", "direction=next", "files=on", "directories=on", "text=" .. prefix)
        DC.ExecuteCommand("cm_QuickSearch", "search=off")
        
    elseif key == "e" then
        DC.ExecuteCommand("cm_Edit")

    elseif key == "R" then
        DC.ExecuteCommand("cm_Refresh")
        
    elseif key == "z" then
        local fn = param[2] .. delim .. "dcvim" .. delim .. "vars" .. delim .. "panel"
        local fp = io.open(fn, "r")
        local w = nil
        if fp ~= nil then
            w = fp:read("*l")
            fp:close()
        end
        if w == nil or w == "" or w == "0" then
            w = 100
            fp = io.open(fn, "w")
            fp:write("1")
            fp:close()
        else
            fp = io.open(fn, "w")
            fp:write("0")
            fp:close()
            fn = param[2] .. delim .. "dcvim" .. delim .. "vars" .. delim .. "panelw"
            fp = io.open(fn, "r")
            if fp ~= nil then
                w = fp:read("*l")
                fp:close()
            end
            if not w:match("%d+") then
                w = 50
            end
        end
        DC.ExecuteCommand("cm_PanelsSplitterPerPos", "splitpct=" .. w)
        
    elseif key == ">" then
        local w = 50
        local fn = param[2] .. delim .. "dcvim" .. delim .. "vars" .. delim .. "panelw"
        local fp = io.open(fn, "r")
        if fp ~= nil then
            w = fp:read("*l")
            if not w:match("%d+") then w = 50 end
            fp:close()
        end
        w = w + 1
        DC.ExecuteCommand("cm_PanelsSplitterPerPos", "splitpct=" .. w)
        fp = io.open(fn, "w")
        fp:write(w)
        fp:close()
        
    elseif key == "<" then
        local w = 50
        local fn = param[2] .. delim .. "dcvim" .. delim .. "vars" .. delim .. "panelw"
        local fp = io.open(fn, "r")
        if fp ~= nil then
            w = fp:read("*l")
            if not w:match("%d+") then w = 50 end
            fp:close()
        end
        w = w - 1
        DC.ExecuteCommand("cm_PanelsSplitterPerPos", "splitpct=" .. w)
        fp = io.open(fn, "w")
        fp:write(w)
        fp:close()

    elseif key == "x" then
    	DC.ExecuteCommand("cm_NetworkDisconnect")

    elseif key == "Q" then
    	DC.ExecuteCommand("cm_Exit")

    end

    return
end


-- clear the mode file
io.open(file_mode, "w"):close()


if mode == "f" then
    local file_find_sym = param[2] .. delim .. "dcvim" .. delim .. "vars" .. delim .. "find_sym"
    local ffile = io.open(file_find_sym, "w")
    ffile:write(key)
    ffile:close()
    DC.ExecuteCommand("cm_QuickSearch", "search=on", "direction=first", "files=on", "directories=on", "text=" .. key)
    DC.ExecuteCommand("cm_QuickSearch", "search=off")
    
elseif mode == "g" then
    if key == "g" then
        DC.ExecuteCommand("cm_GoToFirstEntry")
    elseif key == "j" then
        emulateKey("PageDown", 1)
    elseif key == "k" then
        emulateKey("PageUp", 1)
    elseif key == "f" then
        DC.ExecuteCommand("cm_Search")
    elseif key == "h" then
        DC.ExecuteCommand("cm_ChangeDirToHome")
    elseif key == "i" then
        DC.ExecuteCommand("cm_DirHistory")
    elseif key == "y" then
        DC.ExecuteCommand("cm_SyncDirs")
    elseif key == "." then
        DC.ExecuteCommand("cm_ShowSysFiles")
    elseif key == "b" then
        DC.ExecuteCommand("cm_FlatView")
    elseif key == "s" then
        DC.ExecuteCommand("cm_CountDirContent")
    elseif key == "o" then
        DC.ExecuteCommand("cm_Options")
    elseif key == "t" then
        DC.ExecuteCommand("cm_RunTerm")
    elseif key == "/" then
        DC.ExecuteCommand("cm_ChangeDirToRoot")
    end
    

elseif mode == "s" then
    if key == "n" then
        DC.ExecuteCommand("cm_SortByName")
    elseif key == "s" then
        DC.ExecuteCommand("cm_SortBySize")
    elseif key == "e" then
        DC.ExecuteCommand("cm_SortByExt")
    elseif key == "d" then
        DC.ExecuteCommand("cm_SortByDate")
    elseif key == "a" then
        DC.ExecuteCommand("cm_SortByAttr")
    end
        
elseif mode == "D" then
    if key == "D" then
        DC.ExecuteCommand("cm_Delete", "confirmation=no", "trashcan=off")
    end
        
elseif mode == "d" then
    if key == "d" then
        DC.ExecuteCommand("cm_Delete", "confirmation=no", "trashcan=on")
    end

elseif mode == "y" then
    if key == "y" then
        DC.ExecuteCommand("cm_CopyToClipboard")
    elseif key == "n" then
        DC.ExecuteCommand("cm_CopyNamesToClip")
    elseif key == "f" then
        DC.ExecuteCommand("cm_CopyFullNamesToClip")
    -- elseif key == "v" then
        -- DC.ExecuteCommand("cm_Rename", "confirmation=off")
    elseif key == "d" then
        DC.ExecuteCommand("cm_CutToClipboard")
    -- elseif key == "c" then
        -- DC.ExecuteCommand("cm_CopyNoAsk")
    end
    
elseif mode == "p" then
    if key == "p" then
        DC.ExecuteCommand("cm_PasteFromClipboard")
    end
    
elseif mode == "v" then
    if key == "v" then
        DC.ExecuteCommand("cm_MarkMarkAll")
    elseif key == "u" then
        DC.ExecuteCommand("cm_MarkUnmarkAll")
    elseif key == "i" then
        DC.ExecuteCommand("cm_MarkInvert")
    elseif key == "a" or key == "+" then
        DC.ExecuteCommand("cm_MarkPlus")
    elseif key == "d"  or key == "-" then
        DC.ExecuteCommand("cm_MarkMinus")
    elseif key == "e" then
        -- cm_MarkCurrentExtension selects everything if cursor is on a directory or a file without extension - avoid that
        local ext = SysUtils.ExtractFileExt(param[3])
        if ext ~= nil and ext ~= "" then
            DC.ExecuteCommand("cm_MarkCurrentExtension")
        end
    end
    
elseif mode == "m" then
    if key:len() ~= 1 then return end
    if key:match("%a") or key:match("%d") then
        local curdir = param[4]
        local file_bookmarks = param[2] .. delim .. "dcvim" .. delim .. "vars" .. delim .. "bookmarks"
        local fp = io.open(file_bookmarks, "r")
        local content = {}
        if fp ~= nil then
            for line in fp:lines() do
                if key ~= line:sub(1, 1) then
                    content[#content + 1] = line
                end
            end
            fp:close()
        end
        fp = io.open(file_bookmarks, "w")
        if (#content > 0) then
            for i = 1, #content do
                fp:write(string.format("%s\n", content[i]))
            end
        end
        fp:write(key .. " " .. curdir .. "\n")
        fp:close()
    end
    
elseif mode == "'" or key == "`" then
    if key == "'" or key == "`" then
        DC.ExecuteCommand("cm_DirHotList")
    elseif key:match("%a") or key:match("%d") then
        local file_bookmarks = param[2] .. delim .. "dcvim" .. delim .. "vars" .. delim .. "bookmarks"
        local fp = io.open(file_bookmarks, "r")
        if fp ~= nil then
            for line in fp:lines() do
                if key == line:sub(1, 1) then
                    DC.ExecuteCommand("cm_ChangeDir", "activepath=" .. line:sub(3))
                    break
                end
            end
            fp:close()
        end
    end
    
elseif mode == "c" then
    if key == "p" then
        DC.ExecuteCommand("cm_CopyNoAsk")
    elseif key == "m" then
        DC.ExecuteCommand("cm_Rename", "confirmation=off")
    end

elseif mode == "r" then
	if key == "r" then
        DC.ExecuteCommand("cm_RenameOnly")
    elseif key == "i" then
        DC.ExecuteCommand("cm_RenameOnly")
        emulateKey("Home", 1)
    elseif key == "a" then
        DC.ExecuteCommand("cm_RenameOnly")
        emulateKey("Right", 1)
    elseif key == "e" then
        DC.ExecuteCommand("cm_RenameOnly")
        emulateKey("End", 1)
    elseif key == "m" then
        DC.ExecuteCommand("cm_MultiRename")
    end

elseif mode == "n" then
	if key == "d" then
	    DC.ExecuteCommand("cm_MakeDir")
	elseif key == "f" then
	    DC.ExecuteCommand("cm_EditNew")
	elseif key == "n" then
		DC.ExecuteCommand("cm_NetworkConnect")
	end

end
