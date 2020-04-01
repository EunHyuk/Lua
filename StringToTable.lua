-- LUA 字符串转换为Table的算法

--[[
	paramType 是提前记录每一个记录的类型，以便转化
	str：输入的字符串
	用处：lua字符串转化为table表的时候使用
	LoadString是Lua虚拟机自带的
]]
function ApiTestPanel:_stringToTable(str, paramType)
    local _result = CS.LuaMgr.LoadString("return "..str)

    local strToTable = _result()
    if not strToTable then
    	return {}
    end
    for k,v in pairs(strToTable) do
    	if paramType[k] == "string" then
    		strToTable[k] = tostring(v)
    	elseif paramType[k] == "number" then
    		strToTable[k] = tonumber(v)
    	elseif paramType[k] == "boolean" then
    		if v == true then
    			strToTable[k] = true
    		else
    			strToTable[k] = false
    		end
    	end 
    end
    return strToTable
end

-