local Player = {
    type = "player1";
    
    image = {
        root = {
            "assets/png/character/front.png"
        };
        walking = {
            "assets/png/character/walk/walk0001.png";
            "assets/png/character/walk/walk0002.png";
            "assets/png/character/walk/walk0003.png";
            "assets/png/character/walk/walk0004.png";
            "assets/png/character/walk/walk0005.png";
            "assets/png/character/walk/walk0006.png";
            "assets/png/character/walk/walk0007.png";
            "assets/png/character/walk/walk0008.png";
            "assets/png/character/walk/walk0009.png";
            "assets/png/character/walk/walk0010.png";
            "assets/png/character/walk/walk0011.png";
        };
        jumping = {
            "assets/png/character/jump.png";
        };
        falling = {
            "assets/png/character/jump.png";
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

function Player:update(dt)
    if self.velY < -5 then
        if self.state == 'falling' then
            self.currFrame = self.currFrame + dt

            if self.currFrame - self.lastFrame >= self.frameLen then
                self.lastFrame = self.currFrame
                self.imageState = 1 + (self.imageState % #self.images.falling)
            end
        else
            self.state = 'falling'
            self.imageState = 1
        end
    elseif self.velY > 3 then
        if self.state == 'jumping' then
            self.currFrame = self.currFrame + dt

            if self.currFrame - self.lastFrame >= self.frameLen then
                self.lastFrame = self.currFrame
                self.imageState = 1 + (self.imageState % #self.images.jumping)
            end
        else
            self.state = 'jumping'
            self.imageState = 1
        end
    elseif math.abs(self.velX) > 1 then
        if self.state == 'walking' then
            self.currFrame = self.currFrame + dt

            if self.currFrame - self.lastFrame >= self.frameLen then
                self.lastFrame = self.currFrame
                self.imageState = 1 + (self.imageState % #self.images.walking)
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
                self.imageState = 1 + (self.imageState % #self.images.root)
            end
        else
            self.state = 'root'
            self.imageState = 1
        end
    end
end

function Player:draw()
    if self.images[self.state][self.imageState] then
        local img = self.images[self.state][self.imageState]
        love.graphics.draw(img, math.floor(self.x + 0.5), math.floor(self.y + 0.5), self.angle, self.velX > 0 and 1 or -1, 1, math.floor((img:getWidth()/2) + 0.5), math.floor((img:getHeight()/2) + 0.5))
    end
end

return Player
