-- lua table 转化为string

--[[
	这里只判断了两层嵌套，如果有增加的话要自己修改
	self.paramType是记录了每一个字段的类型，方便之后转化
]]
function TableToStr()
	self.paramType = {}
	local str = "{"
	for k,v in pairs(apiData.Params) do
		if type(v) == "string" then
			str = str..k.."=".."\""..v.."\""..","
		elseif type(v) == "number" then
			str = str..k.."="..v..","
		elseif type(v) == "boolean" then
			str = str..k.."="..tostring(v)..","
		end
		self.paramType[k] = type(v)
		if type(v) == "table" then
			for kk,vv in pairs(v) do
				if type(vv) == "string" then
					str = str..kk.."=".."\""..vv.."\""..","
				elseif type(vv) == "number" then
					str = str..kk.."="..vv..","
				elseif type(vv) == "boolean" then
					str = str..kk.."="..tostring(vv)..","
				end
				self.paramType[kk] = type(vv)
			end
		end
	end
	str = str.."}"
end