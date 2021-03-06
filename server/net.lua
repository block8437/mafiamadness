local mp = require("shared/MessagePack")

require "enet"

mp.set_number('float')
mp.set_array('with_hole')
mp.set_string('string')

local connection_pktid = 1
local creation_pkktid = 2
local movement_pktid = 3
local update_pktid = 4
local destruction_pktid = 5
local chat_pktid = 6
local asset_pktid = 7
local shoot_pktid = 8
local control_pktid = 9
local game_pktid = 10

local clients = {}

local Net = {
    host = nil;
    channel = nil;

    connectCallback = nil;
    disconnectCallback = nil;
    creationCallback = nil;
    movementCallback = nil;
    chatCallback = nil;
    shootCallback = nil;
}

Net.__index = Net

function Net.new(self)
    if self.server == "" then
        error("Unable to connect to an empty server")
        return nil
    end

    self.ip = self.ip or ""

    if self.ip == "connect" then
        error("Channel didn't have a connection on it")
        return nil
    end

    self.host = enet.host_create(self.ip, nil, 11)
    self.server = nil
    self.connected = false

    return setmetatable(self, Net)
end

function Net:createAsset(peer, asset)
    local itmp = asset.image
    local utmp = asset.update
    local dtmp = asset.draw
    local mtmp = asset.move

    asset.image = nil
    asset.update = nil
    asset.draw = nil
    asset.move = nil

    peer:send(mp.pack(asset), asset_pktid, "reliable")

    asset.image = itmp
    asset.update = utmp
    asset.draw = dtmp
    asset.move = mtmp
end

function Net:createObject(peer, id, obj)
    local vx, vy = obj.body:getLinearVelocity()

    local data = {
        id = id;
        asset = obj.asset;
        px = obj.body:getX();
        py = obj.body:getY();
        vx = vx;
        vy = vy;
        a = obj.body:getAngle();
    }

    peer:send(mp.pack(data), creation_pktid, "reliable")
end

function Net:gameState(peer, state, arg)
    local data = {
        state = state;
    }

    if arg then data.arg = arg end

    peer:send(mp.pack(data), game_pktid, "reliable")
end

function Net:control(peer, id)
    local data = {
        id = id;
    }

    peer:send(mp.pack(data), control_pktid, "reliable")
end

function Net:update(peer, id, obj)
    local vx, vy = obj.body:getLinearVelocity()

    local data = {
        id = id;
        px = obj.body:getX();
        py = obj.body:getY();
        vx = vx;
        vy = vy;
        a = obj.body:getAngle();
    }

    if obj.wepAngle then data.wepAngle = obj.wepAngle end

    peer:send(mp.pack(data), update_pktid, "unreliable")
end

function Net:shoot(peer, id)
    local data = {
        id = id;
    }

    peer:send(mp.pack(data), shoot_pktid, "unreliable")
end

function Net:msg(peer, name, msg)
    local data = {
        name = name;
        msg = msg;
    }

    peer:send(mp.pack(data), chat_pktid, "reliable")
end

function Net:destroy(peer, id)
    local data = {
        id = id;
    }

    peer:send(mp.pack(data), destruction_pktid, "unreliable")
end

function Net:parse(peer, channel, data)
    if channel == connection_pktid then
        if self.creationCallback then
            self.creationCallback(peer, mp.unpack(data))
        end
    elseif channel == movement_pktid then
        if self.movementCallback then
            self.movementCallback(peer, mp.unpack(data))
        end
    elseif channel == chat_pktid then
        if self.chatCallback then
            self.chatCallback(peer, mp.unpack(data))
        end
    elseif channel == shoot_pktid then
        if self.shootCallback then
            self.shootCallback(peer, mp.unpack(data))
        end
    end
end

function Net:close()
    self.server:disconnect()
    self.host:flush()
    self.listening = false
end

function Net:listen()
    local event = self.host:service()

    while event do
        if event.type == "connect" then
            if self.connectCallback then
                self.connectCallback(event.peer)
            end
        elseif event.type == "receive" then
            self:parse(event.peer, event.channel, event.data)
        elseif event.type == "disconnect" then
            if self.disconnectCallback then
                self.disconnectCallback(event.peer)
            end
        end

        event = self.host:service()
    end
end

return Net
