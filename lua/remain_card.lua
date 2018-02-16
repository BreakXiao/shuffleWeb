--剩余牌堆接口
package.path = '/lsx/shuffleWeb/lua/?.lua;'
mcard = require("mrcard") --调用redis和card的模块

--local RemainCard = mcard.getrcard()
local dealcard = mcard.getdealcard()
local cjson=require("cjson")
local restable={}
restable["remain_num"]= 52-table.getn(dealcard)
for i,num in pairs(dealcard)
do
	restable[i]=num
end

local resstr=cjson.encode(restable)
ngx.say(resstr)
