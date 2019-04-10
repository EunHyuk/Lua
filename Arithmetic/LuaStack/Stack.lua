-- Lua中没有栈这个操作，对于很多人来说都不适应，我实现了一个呀 喵喵喵
--[[
	使用方法：
	local stack = require(".../stack.lua")
	return stack.new()
]]

-- 压栈
local push = function(self, x)
    assert(x ~= nil)
    self._topIndex = self._topIndex + 1
    self[self._topIndex] = x
end

-- 弹栈
local pop = function(self)
    local ret = self[self._topIndex]
    self[self._topIndex] = nil
    self._topIndex = self._topIndex - 1
    return ret
end

-- 获取栈顶元素
local top = function(self)
    return self[self._topIndex]
end

-- 获取栈的元素个数
local length = function(self)
    return self._topIndex + 1
end

-- 栈是否为空
local isEmpty = function(self)
    return self:length() == 0
end

local clear = function(self)
  for i=0, self._topIndex do
    self[i] = nil
  end

  self._topIndex = -1
end

local methods = {
    push = push,
    pop = pop,
    top = top,
    length = length,
    isEmpty = isEmpty,
    clear = clear,
}

local new = function()
    local r = {_topIndex = -1}
    return setmetatable(r, {__index = methods})
end

return {
    new = new,
}
