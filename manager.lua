local FN	 = require "lib.settings.fn"
local JSON   = require "json"
local STATIC = system.ResourceDirectory
local WRITABLE = system.DocumentsDirectory

local loaded = false
local changed = false
local storeName = "settings"
local group = nil
local store = {}
local _pointer = store

local function storeFileName()
	return storeName .. ".json"
end

local function storeExists(file)

end

local function loadStore( file, dir )
  local path = system.pathForFile( file, dir)
  local contents = ""
  local file = io.open( path, "r" )
  if file then
    -- read all contents of file into a string
    local contents = file:read( "*a" )
    io.close( file )
    store = JSON.decode( contents ) or {}
  end
end

local function saveStore( file, dir )
 local path = system.pathForFile(file, dir)
 local file = io.open(path, "w")
 if file then
  file:write( JSON.encode( store ) )
  io.close( file )
 end
end

local function getCurrentStoreGroup()
	if FN.isDefined(group) then
		if FN.isNil(store[group]) then
			store[group] = {}
		end
		return store[group]
	else
		return store
	end
end

local function storeContains (key)
	return FN.tableHasKey(_pointer, key)
end

local function beginGroup (prefix)
	-- if not FN.isString(prefix) then error("Settings.beginGroup(String) expected. Got " .. type(prefix)) end
	group = prefix
	if FN.isDefined(group) then
		if FN.isNil(store[group]) then
			store[group] = {}
		end
		_pointer = store[group]
	else
		_pointer = store
	end
end

local function endGroup ()
	group = nil
	_pointer = store
end

local function setValue (key, value)
	if _pointer[key] ~= value then
		_pointer[key] = value
		changed = true
	end
	return value
end

local function getValue (key, default)
	if storeContains(key) then
		return _pointer[key]
	else
		return setValue (key, default)
	end
end

local function removeValue (key)
	if storeContains(key) then
		_pointer[key] = nil
	end
end

local function sync ()
	if loaded then
		if changed then
			saveStore(storeFileName(storeName), WRITABLE)
			changed = false
		end
	else
		loadStore(storeFileName(storeName), WRITABLE)
		loaded = true
	end
end

sync()

return {
	STATIC_PATH = STATIC,
	WRITABLE_PATH = WRITABLE,
	beginGroup = beginGroup,
	endGroup = endGroup,
	contains = storeContains,
	value = getValue,
	setValue = setValue,
	sync = sync
}
