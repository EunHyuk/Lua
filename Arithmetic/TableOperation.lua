--[[
   Lua Table的相关操作
]]

Eun = {}
Eun.cjson = require "cjson"

-- Lua 实现面向对象方法
function class(classname, ...)
    local cls = {__cname = classname}

    local supers = {...}
    for _, super in ipairs(supers) do
        local superType = type(super)
        assert(superType == "nil" or superType == "table" or superType == "function",
            string.format("class() - create class \"%s\" with invalid super class type \"%s\"",
                classname, superType))

        if superType == "function" then
            assert(cls.__create == nil,
                string.format("class() - create class \"%s\" with more than one creating function",
                    classname));
            -- if super is function, set it to __create
            cls.__create = super
        elseif superType == "table" then
            if super[".isclass"] then
                -- super is native class
                assert(cls.__create == nil,
                    string.format("class() - create class \"%s\" with more than one creating function or native class",
                        classname));
                cls.__create = function() return super:create() end
            else
                -- super is pure lua class
                cls.__supers = cls.__supers or {}
                cls.__supers[#cls.__supers + 1] = super
                if not cls.super then
                    -- set first super pure lua class as class.super
                    cls.super = super
                end
            end
        else
            error(string.format("class() - create class \"%s\" with invalid super type",
                        classname), 0)
        end
    end

    cls.__index = cls
    if not cls.__supers or #cls.__supers == 1 then
        setmetatable(cls, {__index = cls.super})
    else
        setmetatable(cls, {__index = function(_, key)
            local supers = cls.__supers
            for i = 1, #supers do
                local super = supers[i]
                if super[key] then return super[key] end
            end
        end})
    end

    if not cls.ctor then
        -- add default constructor
        cls.ctor = function() end
    end
    cls.new = function(...)
        local instance
        if cls.__create then
            instance = cls.__create(...)
        else
            instance = {}
        end
        setmetatableindex(instance, cls)
        instance.class = cls
        instance:ctor(...)
        return instance
    end
    cls.create = function(_, ...)
        return cls.new(...)
    end

    return cls
end

-- Copy Table 
function Eun.copyTable(st)
	local tab = {}
	for k,v in pairs(st or {}) do
		if type(v) ~= "table" then
			tab[k] = v
		else
			tab[k] = Eun.copyTable(v)
		end
	end
	return tab
end

--  Output Table
function Eun.outputTable(table, prefix)
	prefix = prefix or ""
	for k,v in pairs(table) do
		print(prefix..k,v)
		if (type(v)=="table" and k ~= "__index") then
			print(prefix.."------table------")
			Otk.outputTable(v, prefix.." ")
			print(prefix.."-------end------")
		end
	end
end

function Eun.jsonDecode(data)
	if data == nil or data == "" then
		Otk.log("cjson decode error: input is nil")
		print(debug.traceback())

		return {}
	end

	local cjson = require "cjson"

	return cjson.decode(data)
end

function Eun.jsonEncode(data)
	if data == nil then
		Otk.log("cjson encode error: input is nil")
		print(debug.traceback())

		return {}
	end

	local cjson = require "cjson"

	return cjson.encode(data)
end

-- 格式化图片名字，去掉其中的/
Eun.formatDLName = function (name)
    local ret, _ = string.gsub(name,"/", "")
    return ret
end

Eun.replaceString = function (input, src, des)
    if input == nil then
        Otk.warn("replace string:input is nil")
        input = ""
    end
    if src == nil then
        Otk.warn("replace string:src is nil")
        src = ""
    end
    if des == nil then
        Otk.warn("replace string:des is nil")
        des = ""
    end

    local ret, _ = string.gsub(input, src, des)
    return ret
end

--[[int转换Bool
]]
function Eun.NumberToBool(value)
    if type(value) == 'boolean' then
        return value
    end
    if Otk.isNullStr(value) then
        return false
    end
    value = tonumber(value)
    if value == nil or value == 0 then
        return false
    end
    return true
end

--[[
    保留小数点n位方法(不会四舍五入,n位后直接舍去)
]]
function Otk.getPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum;
    end
    n = n or 0;
    n = math.floor(n)
    if n < 0 then
        n = 0;
    end
    local nDecimal = 10 ^ n
    local nTemp = math.floor(nNum * nDecimal);
    local nRet = nTemp / nDecimal;
    return nRet;
end

--转换成可以打印的字符串
function Otk.convertLogString(param)
    if Otk.isNullStr(param) then
        return "nil"
    end
    if type(param) == "table" then
        return Otk.jsonEncode(param)
    end

    return param
end


--以指定字符串切割字符串，并返回数组
function Otk.splitString(srcString,separator)
    if Otk.isNullStr(srcString) then
        cclog("splitString error: srcString nil")
        return {}
    end
    if type(srcString) ~= "string" then
        cclog("splitString error: srcString type="..type(srcString))
        return {}
    end
    if Otk.isNullStr(separator) then
        cclog("splitString error: separator nil")
        return {}
    end
    local findStartIndex = 1
    local splitIndex = 1
    local array = {}
    while true do
       local findLastIndex = string.find(srcString, separator, findStartIndex)
       if not findLastIndex then
            array[splitIndex] = string.sub(srcString, findStartIndex, string.len(srcString))
            break
       end
       array[splitIndex] = string.sub(srcString, findStartIndex, findLastIndex - 1)
       findStartIndex = findLastIndex + string.len(separator)
       splitIndex = splitIndex + 1
    end
    return array
end

--对字符串所有字符以空格隔开
function Otk.separatorString(str,defaultStr)
    if Otk.isNullStr(str) then
        return defaultStr or ""
    end
    local length = string.len(str)
    local array = {}
    for i=1,length do
        table.insert(array,string.sub(str,i,i))
    end
    return table.concat(array," ")
end


-- 去除字符串两边的空格
function Otk.trimString(s)
    if type(s) ~= "string" then
        cclog("Otk.trimString 类型不匹配无法trim")
        return s
    end
    --cclog("trim前="..s..",trim后="..(string.gsub(s, "^%s*(.-)%s*$", "%1")))
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

--首字母大写
function Otk.getFirstUpperString(str)
    if Otk.isNullStr(str) then
        return ""
    end
    return string.upper(string.sub(str,1,1))..string.sub(str,2)
end

--判断是否是有效点击事件 触摸点之间的距离不超过distance距离
function Otk.isValidTouch(startPos,endPos,distance)
    if not startPos or not endPos then
        return false
    end
    if distance == nil then
        distance = 20
    end

    local deltaX = math.abs(startPos.x - endPos.x)
    local deltaY = math.abs(startPos.y - endPos.y)
    if deltaX >= distance or deltaY >= distance then
        return false
    end

    return true
end

--// The Save Function
function Otk.saveTable(tbl, filename)
  local charS,charE = "   ","\n"
  local file,err = io.open( filename, "wb" )
  if err then return err end

  -- initiate variables for save procedure
  local tables,lookup = { tbl },{ [tbl] = 1 }
  file:write( "return {"..charE )

  for idx,t in ipairs( tables ) do
     file:write( "-- Table: {"..idx.."}"..charE )
     file:write( "{"..charE )
     local thandled = {}

     for i,v in ipairs( t ) do
        thandled[i] = true
        local stype = type( v )
        -- only handle value
        if stype == "table" then
           if not lookup[v] then
              table.insert( tables, v )
              lookup[v] = #tables
           end
           file:write( charS.."{"..lookup[v].."},"..charE )
        elseif stype == "string" then
           file:write(  charS..Otk.exportstring( v )..","..charE )
        elseif stype == "number" then
           file:write(  charS..tostring( v )..","..charE )
        end
     end

     for i,v in pairs( t ) do
        -- escape handled values
        if (not thandled[i]) then

           local str = ""
           local stype = type( i )
           -- handle index
           if stype == "table" then
              if not lookup[i] then
                 table.insert( tables,i )
                 lookup[i] = #tables
              end
              str = charS.."[{"..lookup[i].."}]="
           elseif stype == "string" then
              str = charS.."["..Otk.exportstring( i ).."]="
           elseif stype == "number" then
              str = charS.."["..tostring( i ).."]="
           end

           if str ~= "" then
              stype = type( v )
              -- handle value
              if stype == "table" then
                 if not lookup[v] then
                    table.insert( tables,v )
                    lookup[v] = #tables
                 end
                 file:write( str.."{"..lookup[v].."},"..charE )
              elseif stype == "string" then
                 file:write( str..Otk.exportstring( v )..","..charE )
              elseif stype == "number" then
                 file:write( str..tostring( v )..","..charE )
              end
           end
        end
     end
     file:write( "},"..charE )
  end
  file:write( "}" )
  file:close()

    if CS.UnityEngine.Application.platform ~= CS.UnityEngine.RuntimePlatform.OSXEditor and
    CS.UnityEngine.Application.platform ~= CS.UnityEngine.RuntimePlatform.WindowsEditor then
        CS.LuaMgr.ef(filename)
    end
end

--// The Load Function
function Otk.loadTable( sfile )
    local ftables = require (sfile)
    if not ftables then

    end
    local tables = ftables
    for idx = 1,#tables do
        local tolinki = {}
        for i,v in pairs( tables[idx] ) do
            if type( v ) == "table" then
               tables[idx][i] = tables[v[1]]
            end
            if type( i ) == "table" and tables[i[1]] then
               table.insert( tolinki,{ i,tables[i[1]] } )
            end
        end
        -- link indices
        for _,v in ipairs( tolinki ) do
            tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
        end
    end
    return tables[1]
end

