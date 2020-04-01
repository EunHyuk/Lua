--[[
String 的切分转换为table
]]
function string.split(str, delimiter)
	if str==nil or str=='' or delimiter==nil then
		return nil
	end

    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

--[[
	Lua 加载卸载管理
]]

local fileMap = {}
function OtkRequire(filepath)
    fileMap[filepath] = 1
    return require(filepath)
end

function OtkUnloadRequire( ... )
    for k,v in pairs(fileMap) do
        package.loaded[k] = nil
    end
end

--[[
	打印Table
]]

function Otk.outputTable(table, prefix)
  prefix=prefix or ""
  for k,v in pairs(table) do
      print(prefix..k,v)
      if(type(v)=="table" and k~="__index") then
          print(prefix.."-----table-----")
          Otk.outputTable(v,prefix.."  ")
          print(prefix.."------end------")
      end
  end
end

--[[
	复制Table
]]
function Otk.copyTable(st)
  local tab = {}
    for k, v in pairs(st or {}) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = Otk.copyTable(v)
        end
    end
    return tab
end

function Otk.copyArray(src,dst,checkFunc)
    if not src or #src == 0 then
        return false
    end
    if not dst then
        return false
    end
    for i,v in ipairs(src) do
        if not checkFunc or checkFunc(dst,v) then
            table.insert(dst,v)
        end
    end
    return true
end

-- 随机数的选取，可用系统时间
function Otk.initRandSeed()
  if not Otk.isRandomized then
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    Otk.isRandomized = true
  end
end

function Otk.random_i_m_n(m,n)
    Otk.initRandSeed()

    return math.random(m,n)
end

function Otk.callInSec(sec, callback)
	local co = coroutine.create(function()
	    coroutine.www(CS.UnityEngine.WaitForSeconds(sec))

	    callback()
	end)

	coroutine.resume(co)
end

-- json解压
function Otk.jsonDecode(data)
	if data == nil or data == "" then
		Otk.log("cjson decode error: input is nil")
		print(debug.traceback())

		return {}
	end

	-- local cjson = require "cjson"
	-- return cjson.decode(data)
    return Otk.cjson.decode(data)
end

function Otk.jsonEncode(data)
	if data == nil then
		Otk.log("cjson encode error: input is nil")
		print(debug.traceback())

		return {}
	end

	-- local cjson = require "cjson"
	-- return cjson.encode(data)
    return Otk.cjson.encode(data)
end

Otk.replaceString = function (input, src, des)
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

--[[
    计算 UTF8 字符串的长度，每一个中文算一个字符
]]
function string.utf8len(input)
    local len  = string.len(input)
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(input, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

-- 创建Stack
function Otk.createStack()
	local stack = OtkRequire("src/common/stack.lua")
	return stack.new()
end




