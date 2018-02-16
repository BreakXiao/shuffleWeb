--发牌接口，
--根据剩余牌堆和发牌数量发牌
--
--


--retTable:发送表，存储信息，转成json格式后发送给前端
retTable={}

--deal():发牌函数
--参数为剩余牌堆 和 发牌数
function deal(remain_card, num, randseed)
	--lua调用ostime所得到的时间为秒级，可结合前端传来的随机数来产生随机种子
        math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6))*randseed*randseed)
        local dealnum = num   --发牌数
        local cardnum = #remain_card  --牌堆数，现在为52
        local randnum = 0
        local card = remain_card
        local ans = {}
        while( dealnum ~= 0)
        do
		--每次随机到一个后，从该表中剔除，减少重复
        	randnum = math.random(1,cardnum)
                table.insert(ans, card[randnum])
                table.remove(card,randnum)
                dealnum = dealnum - 1
                cardnum = cardnum - 1
   	end
        return ans
end
        
--输出函数
--现在不做处理，只输出数字
function putcard(res)
        for i,num in ipairs(res)
        do
		retTable[i] = num
        end
end


--接口运行部分


--获取post得到的发牌数dealnum
local rcard = require("mrcard")
ngx.req.read_body()
post_args = ngx.req.get_post_args()
local DealNum = 10
DealNum = post_args["dealn"]
local RandSeed = post_args["randseed"]

--判断发牌数和剩余牌堆数的大小
--shuffleflag决定是否洗牌
local num = 5
num = DealNum + 0
local RemainCard = rcard.getrcard()
retTable["shuffleflag"]="N"
if(num > #RemainCard)
then
	RemainCard = rcard.shuffle()
	retTable["shuffleflag"]="Y"
end



--开始发牌，并存入retTable表
local res = deal(RemainCard,num,RandSeed)
putcard(res)

--在剩余牌库中剔除已经发出的牌
rcard.delecard(res)

--置剩余牌堆数
retTable["Remain_card"] = #RemainCard - num

--用cjson库进行发送
local cjson=require("cjson")
local jsonstr=cjson.encode(retTable)
ngx.say(jsonstr)

