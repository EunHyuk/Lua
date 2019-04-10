自己实现了打字效果的方法，但最终放弃了这个方法，因为不能支持UBB语法，但是记录一下吧

-- 打字效果控件

TextTypeEffect = class("TextTypeEffect", nil)

TextTypeEffect.__index = nil

TextTypeEffect.Mode = {

-- 空闲中

None = 0,

-- 停止中

Stop = 1,

-- 打字中

Type = 2,

}

function TextTypeEffect:create(textNode, callBack)

local node = TextTypeEffect.new()

node:init(textNode, callBack)

return node

end

function TextTypeEffect:init(textNode, callBack)

self.textNode = textNode

self.callBack = callBack

self.mode = TextTypeEffect.Mode.None

FairyGUIMgr.addOnRemovedFromStage(self.textNode,function()

self:stopType()

end)

end

function TextTypeEffect:FormatText(content, len)

if content==nil then

        return ""

    end

    -- 计算多字节字符数

    local lengthUTF_8 = #(string.gsub(content, "[\128-\191]", ""))

    if lengthUTF_8 <= len then

    self:stopType()

    if self.callBack then self.callBack() end

        return content

    else

        local matchStr = "^"

        for var=1, len do

            matchStr = matchStr..".[\128-\191]*"

        end

        local str = string.match(content, matchStr)

        return string.format("%s",str)

    end

end

-- 开始打字

function TextTypeEffect:startType(content)

self.num = 1

self.content = content

self.mode = TextTypeEffect.Mode.Type

self.timer = OtkTimer:create(self:getInterval(),

function()

self.textNode.text = self:FormatText(content, self.num)

self.num = self.num + 1

end,

true

)

end

function TextTypeEffect:getTypeStatus()

return self.mode

end

-- 停止打字

function TextTypeEffect:stopType( ... )

if self.mode == TextTypeEffect.Mode.Stop then

return

end

if self.timer then

self.textNode.text = self.content

self.mode = TextTypeEffect.Mode.Stop

self.timer:stop()

end

end

function TextTypeEffect:setInterval(interval)

self.interval = interval

end

function TextTypeEffect:getInterval()

if self.interval then

return self.interval

else

return 100

end

end