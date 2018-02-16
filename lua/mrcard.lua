--文件名为mrcard.lua
--用来获取redis中card数据的模块
--定义一个名为mrcard的模块
--请记得先配置文件间的依赖关系，并保证path路径能搜查到你所需要的模块。
--card：是一个集合，指代剩余牌库
--ddealcard：是一个列表，用来获取已发牌，用于网页的初始化
mrcard = {}
--连通redis数据库操作
local function open_redis()
    local redis = require("resty.redis")
    local red = redis:new()
    red:set_timeout(1000)
    local ip = "127.0.0.1"
    local port = 6379
    local ok, err = red:connect(ip, port)
    if not ok then
        ngx.say("connect to redis error : ", err)
        return close_redis(red)
    end    
    return red

end

--关闭redis数据库连接
local function close_redis(red)  
        if not red then  
            return  
        end  
        local ok, err = red:close()  
        if not ok then  
            ngx.say("close redis error : ", err)  
        end  
end  

-- 获取剩余牌堆函数
function mrcard.getrcard()
    local red = open_redis()
    local resp, err = red:smembers("card")  
    if not resp then  
        ngx.say("get msg error : ", err)  
        close_redis(red)  
    end  
   
    if resp == ngx.null then  
        resp = ''  
    end
 
    close_redis(red)
    return resp
end

--获取已经被发过的牌，用于页面初始化
function mrcard.getdealcard()
    local red = open_redis()
    --local resp,err = red:smembers("dealcard")
    local resp,err = red:lrange("ddealcard",0,53)
    if resp == ngx.null then
	resp = ''
    end

    close_redis(red)
    return resp
end


--洗牌操作
--需要重置牌库，同时清除已发牌
function mrcard.shuffle()
	local red = open_redis()
	local res = {}
	for i=1,52
	do
		red:sadd("card",i)
		res[i] = i
	--	red:srem("dealcard",'0'+i)
		red:lpop("ddealcard")
	end
	close_redis(red)
	return res
end



--发牌后的数据库操作：在牌库中剔除，以及给已发牌中添加
function mrcard.delecard(delcard)
    local red = open_redis()
    for i,num in pairs(delcard)
    do
        red:srem("card",'0' + num)
	--red:sadd("dealcard",num)
	red:rpush("ddealcard",num)
    end
    
    close_redis(red)
end

return mrcard
