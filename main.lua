local donkey, w_height, w_width, s_height, s_width, buckets, life, points, remainingPointsUntilBonus
local ai, level, soundbank, strategy, strategyseq, intervalTime
local beer, beercontainer, time, MAX_LEVEL, INTERVAL, MAX_BEER, bombInterval
-- TODO: MAIN SCREEN
function love.load()
    love.window.setTitle('Donkey in Trouble - Alpha')
    love.mouse.setVisible(false)
    w_height = love.graphics.getHeight()
    w_width = love.graphics.getWidth()
    s_height = w_height - 270 
    s_width = w_width - 60
    gameInit()
    computerInit()
    bucketInit()
    soundInit()
    font = love.graphics.newFont('fonts/Purisa-Bold.otf',30)
    love.graphics.setFont(font)
end

function gameInit()
    remainingPointsUntilBonus = 0
    bombInterval = 1
    MAX_BEER = 10
    MAX_LEVEL = 10
    INTERVAL = 10
    strategyseq  = {1,1,1, 2,2,2,1,1,1,2}
    intervalTime = INTERVAL
    life = 3
    time = love.timer.getTime()
    level = 1
    points = 0
end

function soundInit()
    soundbank = {}
    soundbank.boom = love.audio.newSource('sounds/boom.ogg', 'static')
    soundbank.dropdown = love.audio.newSource('sounds/dropdown.ogg', 'static')
    soundbank.intermission = love.audio.newSource('sounds/intermission.ogg', 'static')
    soundbank.gotcha = love.audio.newSource('sounds/gotcha.ogg', 'static')
end

function backgroundGen(x,y) 
    love.graphics.setColor(114, 159, 207)
    love.graphics.rectangle("fill", x,y, s_width, 110)
    love.graphics.setColor(85, 87, 83)
    love.graphics.rectangle("fill", x,y*2+30,s_width, s_height)
end

function computerInit() 
    beercontainerInit()
    strategy = {}
    donkey = love.graphics.newImage('objects/donkey.png')
    beer = love.graphics.newImage('objects/beer.png')
    ai = {}
    ai.x = 60
    ai.y = 90

    strategy[1] = function()
        math.randomseed(os.time())
        to_x = math.random(104/2, s_width-104/2)
        if ai.x == to_x then
            to_x = math.random(104/2, s_width-104/2)
        end

        if ai.x < to_x then 
            ai.x = ai.x + level * 2
        end
        if ai.x > to_x then 
            ai.x = ai.x - level * 2
        end
    end

    strategy[2] = function() 
        ai.x = 50 + math.abs(math.cos(os.time()) * (s_width - 50))
    end
end

function beercontainerInit()
    beercontainer = {}
end

function bucketInit()
    buckets = {}
    buckets.y = s_height + 76
    buckets.x = s_width/2
end

function setDifficulty(n)
    bombInterval = bombInterval - 0.1*level
    --PF
    print(level)
    beercontainerInit()
    soundbank.intermission:play()
    if (level < MAX_LEVEL) then
        level = level + n
    end
    love.timer.sleep(1)
    intervalTime = INTERVAL
end

function bucketDraw(number)
    -- FIX: draw from top to bottom
    for i=1,number do    
        love.graphics.setColor(245 - i * 20,121,0)
        love.graphics.rectangle("fill", buckets.x,  buckets.y + 30*i, 60, 20)
    end
end

function newBomb()
    table.insert(beercontainer, {x = ai.x, y = ai.y +40})
end

function removeBomb(bomb)
    table.remove(beercontainer, bomb)
end

function hasMoreBeer()
    return #beercontainer < MAX_BEER
end

function bgtext()
    -- CHANGE FONT AND SIZE
    love.graphics.setColor(117,80,123)
    love.graphics.print('Silly Addicted Donkey', s_width/2 - 150, s_height + 200)
    love.graphics.print(points, s_width/2, 30)
end


function beerDraw()
    local i = 1 
    while (i <= #beercontainer) do
        love.graphics.draw(beer, beercontainer[i].x,beercontainer[i].y)
        i = i + 1
    end
end

function AI()
    -- multiple bomb
    local qtime = love.timer.getTime()
    if hasMoreBeer() and ((qtime - time) > bombInterval)  then
        time = love.timer.getTime()
        newBomb()
        soundbank.dropdown:play()
    end
    strategy[strategyseq[level]]()
end

function beerPhysics()
    local i = 1
    while (i <= #beercontainer) do
        beercontainer[i].y = beercontainer[i].y + 5
        i = i + 1
    end
end

function love.draw()
    backgroundGen(30,80) 
    love.graphics.draw(donkey, ai.x, ai.y)
    bucketDraw(life)
    bgtext()
    beerDraw()
end

function checkCollision()

    local i = 1
    local nbeer = #beercontainer
    while (i <= nbeer) do
        if beercontainer[i].y <= s_height + 160 then
            if beercontainer[i].y >=  buckets.y and beercontainer[i].x  >= buckets.x 
                and beercontainer[i].x <= buckets.x + 60     then
                points = points + level
                remainingPointsUntilBonus = remainingPointsUntilBonus + level
                removeBomb(i)
                nbeer = nbeer -1
                if (remainingPointsUntilBonus >= 1000 and life < 3) then
                    life = life +1
                    remainingPointsUntilBonus = 0
                end
                soundbank.gotcha:play()
            end
        else 
            -- FIX FLASH SCREEN
            -- CHECK IF GAME IS OVER
            removeBomb(i)
            nbeer = nbeer -1
            life = life -1
            soundbank.boom:play()
            if(level >1) then
                setDifficulty(-1)
            end
        end
        i = i + 1
    end
end

function love.update(dt)
    if intervalTime > 0 then
        mouse_x = love.mouse.getX()
        if (mouse_x > 30 and mouse_x <= s_width - 20) then
            buckets.x = mouse_x
        end
        AI()
        beerPhysics()
        checkCollision()
        intervalTime = intervalTime - dt
    else
        setDifficulty(1)
    end
end
