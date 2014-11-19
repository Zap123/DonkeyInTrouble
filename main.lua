local donkey, w_height, w_width, s_height, s_width, buckets, life, points
local ai, level, soundbank, strategy, strategyseq, intervalTime, iteratortail, iteratorhead
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
    strategy = {}
    donkey = love.graphics.newImage('objects/donkey.png')
    beer = love.graphics.newImage('objects/beer.png')
    beercontainerInit()
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
    iteratorInit()
    beercontainer = {}
    for i=1, MAX_BEER do
        beercontainer[i] = {x = 0, y = 0, thrown = false}
    end
end

function bucketInit()
    buckets = {}
    buckets.y = s_height + 76
    buckets.x = s_width/2
end

function increaseDifficulty(n)
    bombInterval = bombInterval - 0.1*level
    --PF
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
    print("new : tail %n") 
    iteratortail = (iteratortail + 1) %(MAX_BEER) 
    if iteratortail == 0 then iteratortail = 1 end
    beercontainer[iteratortail].thrown = true
    beercontainer[iteratortail].x = ai.x
    beercontainer[iteratortail].y = ai.y + 40
    print(iteratortail)
end

function removeBomb()
    print("rm : head %d")
    beercontainer[iteratortail].thrown = false
    iteratorhead = (iteratorhead +1) %(MAX_BEER)
    if iteratorhead == 0 then iteratorhead = 1 end
    print(iteratorhead)
end

function iteratorInit()
    iteratorhead = 1 
    iteratortail = 0
end

function emptycontainer()
    return iteratorhead ~= (iteratortail %MAX_BEER) 
end

function bgtext()
    -- CHANGE FONT AND SIZE
    love.graphics.setColor(117,80,123)
    love.graphics.print('Silly Addicted Donkey', s_width/2 - 150, s_height + 200)
    love.graphics.print(points, s_width/2, 30)
end


function beerDraw()
    local i = iteratorhead 
    while (i <= iteratortail and beercontainer[i].thrown) do
        love.graphics.draw(beer, beercontainer[i].x,beercontainer[i].y)
        i = i + 1
    end
end

function AI()
    local qtime = love.timer.getTime()
    if emptycontainer() and ((qtime - time) > bombInterval)  then
        time = love.timer.getTime()
        newBomb()
        soundbank.dropdown:play()
    end
    strategy[strategyseq[level]]()
end

function beerPhysics()
    local i = iteratorhead
    while (i <= iteratortail and beercontainer[i].thrown) do
        beercontainer[i].y = beercontainer[i].y + 10 
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

    local i = iteratorhead
    while (i <= iteratortail and beercontainer[i].thrown) do
        if beercontainer[i].y <= s_height + 160 then
            if beercontainer[i].y >=  buckets.y and beercontainer[i].x  >= buckets.x 
                and beercontainer[i].x <= buckets.x + 60     then
                points = points + 2* level
                removeBomb()
                -- AFTER 1000 POINTS LIFE UP
                soundbank.gotcha:play()
            end
        else 
            -- FIX FLASH SCREEN
            -- CHECK IF GAME IS OVER
            removeBomb()
            life = life -1
            soundbank.boom:play()
            if(level >1) then
                increaseDifficulty(-1)
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
        increaseDifficulty(1)
    end
end
