local donkey, w_height, w_width, s_height, s_width, b_x, b_y, life, points
local ai_x, ai_y, level
local beer, beercontainer, time
-- FIX: SOUND
-- MAIN SCREEN
function love.load()
    love.mouse.setVisible(false)
    donkey = love.graphics.newImage('objects/donkey.png')
    beer = love.graphics.newImage('objects/beer.png')
    w_height = love.graphics.getHeight()
    w_width = love.graphics.getWidth()
    -- FIX THIS NEED REFACTORING
    s_height = w_height - 270 
    s_width = w_width - 60
    b_y = s_height + 76
    b_x = s_width/2
    life = 3
    ai_x = 60
    ai_y = 90
    time = love.timer.getTime()
    level = 1
    points = 0
    beercontainer = {}
    love.window.setTitle('Donkey in Trouble - Alpha')
end

function backgroundGen(x,y) 
    love.graphics.setColor(114, 159, 207)
    love.graphics.rectangle("fill", x,y, s_width, 110)
    love.graphics.setColor(85, 87, 83)
    love.graphics.rectangle("fill", x,y*2+30,s_width, s_height)
end

function bucket(number)
    -- FIX: draw from top to bottom
    for i=1,number do    
        love.graphics.setColor(245 - i * 20,121,0)
        love.graphics.rectangle("fill", b_x,  b_y + 30*i, 60, 20)
    end
end

function bgtext()
    -- CHANGE FONT AND SIZE
    love.graphics.setColor(117,80,123)
    love.graphics.print('Sad Addicted Donkey', s_width/2- 40, s_height + 200)
    love.graphics.print(points, s_width/2, 50)
end


function beerbomb()
    for i=1,#beercontainer do
        love.graphics.draw(beer, beercontainer[i][1],beercontainer[i][2])
    end
end

function AI()
-- FIX: ADD MORE THAN ONE BEHAVIOUR
--  ai_x = math.abs(math.cos(step) * (s_width))                           
math.randomseed(os.time())
to_x = math.random(104/2, s_width-104/2)
-- FIX INCREASE DIFFICULTY, PAUSE
local qtime = love.timer.getTime()
if #beercontainer <= 10 and qtime - time > 1 then
    time = love.timer.getTime()
    table.insert(beercontainer, {ai_x, ai_y+40})
end
if ai_x == to_x then
    to_x = math.random(104/2, s_width-104/2)
end

if ai_x < to_x then 
    ai_x = ai_x + level * 2
end
if ai_x > to_x then 
    ai_x = ai_x - level * 2
end
end

function beerUpdate()
    for i=1,#beercontainer do
        beercontainer[i][2] = beercontainer[i][2] + 10 
    end
end

function love.draw()
    backgroundGen(30,80) 
    love.graphics.draw(donkey, ai_x, ai_y)
    bucket(life)
    bgtext()
    beerbomb()
end

function checkCollision()
    for i=1, #beercontainer do
       if beercontainer[i][2] <= s_height + 160 then
       if beercontainer[i][2] >=  b_y and beercontainer[i][1]  >= b_x 
              and beercontainer[i][1] <= b_x + 60     then
              table.remove(beercontainer,i)
              points = points + 2* level
              print("Gotcha")
              -- AFTER 1000 POINTS LIFE UP
       end
       else 
           -- FIX FLASH SCREEN
           -- CHECK IF GAME IS OVER
           -- LOWER DIFFICULTY
              table.remove(beercontainer,i)
              life = life -1
   end
    end
end

function love.update(dt)
    mouse_x = love.mouse.getX()
    if (mouse_x > 30 and mouse_x <= s_width - 20) then
        b_x = mouse_x
    end
    AI()
    beerUpdate()
    checkCollision()
end
