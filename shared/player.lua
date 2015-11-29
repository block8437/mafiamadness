
package.path = package.path .. ";../?.lua"

local Player = {
    type = "player1";

    image = {
        root = {
            love.graphics.newImage("shared/assets/png/character/front.png")
        };
        walking = {
            love.graphics.newImage("shared/assets/png/character/walk/walk0001.png");
            love.graphics.newImage("shared/assets/png/character/walk/walk0002.png");
            love.graphics.newImage("shared/assets/png/character/walk/walk0003.png");
            love.graphics.newImage("shared/assets/png/character/walk/walk0004.png");
            love.graphics.newImage("shared/assets/png/character/walk/walk0005.png");
            love.graphics.newImage("shared/assets/png/character/walk/walk0006.png");
            love.graphics.newImage("shared/assets/png/character/walk/walk0007.png");
            love.graphics.newImage("shared/assets/png/character/walk/walk0008.png");
            love.graphics.newImage("shared/assets/png/character/walk/walk0009.png");
            love.graphics.newImage("shared/assets/png/character/walk/walk0010.png");
            love.graphics.newImage("shared/assets/png/character/walk/walk0011.png");
        };
        jumping = {
            love.graphics.newImage("shared/assets/png/character/jump.png");
        };
        falling = {
            love.graphics.newImage("shared/assets/png/character/jump.png");
        }
    };

    state = 'root';
    imageState = 1;

    lastFrame = 0.0;
    currFrame = 0.0;
    frameLen = 0.03;
}

Player.__index = Player

function Player.new(self)
    self.id = self.id or 0

    self.x = self.x or 0
    self.y = self.y or 0

    self.velX = self.velX or 0
    self.velY = self.velY or 0

    self.angle = self.angle or 0

    return setmetatable(self, Player)
end

function Player:createPhysics(world)
    self.w = self.w or self.image['root'][1]:getWidth()
    self.h = self.h or self.image['root'][1]:getHeight()

    self.body = love.physics.newBody(world, self.x, self.y, "dynamic")
    self.shape = love.physics.newRectangleShape(0, 0, self.w, self.h)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)

    self.body:setFixedRotation(true)
    self.body:setUserData(self)
end

function Player:applyMovement(mvt)
    if mvt.up == 1 then
        local _, y = self.body:getLinearVelocity()
        if math.abs(y) < 7 then
            self.body:applyLinearImpulse(0, self.body:getMass() * love.physics.getMeter()*-5)
        end
    end

    if mvt.left == 1 then
        self.body:applyLinearImpulse(-20 * self.body:getMass(), 0)
    end

    if mvt.right == 1 then
        self.body:applyLinearImpulse(20 * self.body:getMass(), 0)
    end
end

function Player:update(dt)
    local x, y = self.body:getLinearVelocity()

    if y < -5 then
        if self.state == 'falling' then
            self.currFrame = self.currFrame + dt

            if self.currFrame - self.lastFrame >= self.frameLen then
                self.lastFrame = self.currFrame
                self.imageState = 1 + (self.imageState % #self.image.falling)
            end
        else
            self.state = 'falling'
            self.imageState = 1
        end
    elseif y > 3 then
        if self.state == 'jumping' then
            self.currFrame = self.currFrame + dt

            if self.currFrame - self.lastFrame >= self.frameLen then
                self.lastFrame = self.currFrame
                self.imageState = 1 + (self.imageState % #self.image.jumping)
            end
        else
            self.state = 'jumping'
            self.imageState = 1
        end
    elseif math.abs(x) > 1 then
        if self.state == 'walking' then
            self.currFrame = self.currFrame + dt

            if self.currFrame - self.lastFrame >= self.frameLen then
                self.lastFrame = self.currFrame
                self.imageState = 1 + (self.imageState % #self.image.walking)
            end
        else
            self.state = 'walking'
            self.imageState = 1
        end
    else
        if self.state == 'root' then
            self.currFrame = self.currFrame + dt

            if self.currFrame - self.lastFrame >= self.frameLen then
                self.lastFrame = self.currFrame
                self.imageState = 1 + (self.imageState % #self.image.root)
            end
        else
            self.state = 'root'
            self.imageState = 1
        end
    end
end

local function round(x)
    return math.floor(x + 0.5)
end

function Player:draw(prediction)
    if self.image[self.state][self.imageState] then
        local img = self.image[self.state][self.imageState]

        local x, y, angle, velX
        x, y = self.body:getX(), self.body:getY()
        angle = self.body:getAngle()
        velX = select(1, self.body:getLinearVelocity())

        love.graphics.draw(img, round(x), round(y), angle, velX < -1 and -1 or 1, 1, round((img:getWidth()/2)), round((img:getHeight()/2)))
    end
end

return Player
