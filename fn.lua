
local pairs = pairs
local error = error
local type = type

local function _i (n) return n + 1 end
local function _d (n) return n - 1 end
local function _c (a, min, max) if max and a > max then a = max end; if min and a < min then a = min end; return a end

-- isTable, isNumber, isString, isFunction, isBoolean, isNil - object type testers
local function isTable ( obj )
        return type(obj) == "table"
end
local function isNumber ( obj )
        return type(obj) == "number"
end
local function isZero ( obj )
        return isNumber(obj) and obj == 0
end
local function isString ( obj )
        return type(obj) == "string"
end
local function isEmptyString ( obj )
        return isString(obj) and obj == ""
end
local function isFunction ( obj )
        return type(obj) == "function"
end
local function isBoolean ( obj )
        return type(obj) == "boolean"
end
local function isNil ( obj )
        return type(obj) == "nil"
end
-- isDefined - checks if object exists
local function isDefined  (object)
        return not isNil(object)
end

-- tableHasKey - checks if table has a specific key and retrurn TRUE if it does
local function tableHasKey (tbl, key)
        return tbl[key] ~= "nil"
end

local function ifThen (test, yes, no)
		if test then return yes
			else return no end
end

-- tableKeys - get a table of keys from the source table
local function tableKeys (tbl)
        if not isTable( tbl ) then return error("Could not extract keys. Object is not a table.") end
        local keys = {}
        local n = 0
        
        for key, value in pairs(tbl) do
          n = n + 1
          keys[n] = key
        end
        return keys
end

-- Iterator - create an iterator object from source table
local function Iterator (tbl)
        if not isTable( tbl ) then return error("Could not create an Iterator. Object is not a table.") end
        local obj = tbl
        local keys = tableKeys(tbl)
        local length = #keys
        local cursor = 0
        local iterator = {}
        
        local function _cursor()
          return _c( cursor, 1, length)
        end
        local function _hasNext()
                return _i(cursor) < _i(length)
        end
        local function _hasPrevious()
                return _d(cursor) > _d(length)
        end
        local function _key()
                return keys[_cursor()]
        end
        local function _val()
                return obj[keys[_cursor()]]
        end
		local function _len()
                return length
        end
		local function _next()
                if not _hasNext() then return nil end
                cursor = _c( _i(cursor) , 1, length)
                local key, val = _key(), _val()
                return key, val
        end
		local function _previous()
                if not _hasPrevious() then return nil end
                cursor = _c( _d(cursor) , 1, length)
                local key, val = _key(), _val()
                return key, val
        end
		local function _total()
                return length
        end
		local function _getCursor()
                return _cursor()
        end
		local function _setCursor()
                cursor = _c( i, 1, length)
        end
		local function _toBeginning()
                cursor = 0
        end
		local function _toEnd()
                cursor = length
        end
        
        return {
			total = _total,
			hasNext = _hasNext,
			hasPrevious = _hasPrevious,
			key = _key,
			value = _val,
			next = _next,
			previous = _previous,
			getCursor = _getCursor,
			setCursor = _setCursor,
			toBeginning = _toBeginning,
			toEnd = _toEnd
		}
end

-- tableCopy - create a shallow copy of the source table
local function tableCopy ( tbl )
        if not isTable( tbl ) then return error("Could not create a copy. Object is not a table.") end
        local iterator = Iterator (tbl)
        local res = {}
        for k,v in iterator.next do
          res[k] = v
        end
        return res
end

-- tableExtend - copy keys from source table to the destination table
local function tableExtend ( dest, src )
        if not isTable( dest ) then return error("Destination is not a table.") end
        if not isTable( src ) then return dest end
        local iterator = Iterator (src)
        for k,v in iterator.next do
          dest[k] = v
        end
        return dest
end

-- tableHasRequiredKeys -- check if the required keys are present in the table and their values is not a nil
local function tableHasKeys ( tbl, rec )
        if not isTable( tbl ) then return error("Destination is not a table.") end
        if not isTable( rec ) then return error("Requirement is not a table.") end
        local iterator = Iterator (rec)
        while iterator.next() do
                if not tableHasKey( tbl, iterator.value() ) or tbl[iterator.value()] == nil then
                        return false
                end
        end
        return true
end

return {
	isTable = isTable,
	isNumber = isNumber,
	isZero = isZero,
	isString = isString,
	isEmptyString = isEmptyString,
	isFunction = isFunction,
	isBoolean = isBoolean,
	isNil = isNil,
	isDefined = isDefined,
	ifThen = ifThen,
	tableHasKey = tableHasKey,
	tableKeys = tableKeys,
	Iterator = Iterator,
	tableCopy = tableCopy,
	tableExtend = tableExtend,
	tableHasKeys = tableHasKeys
}
