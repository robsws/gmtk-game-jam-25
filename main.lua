-- CONSTANTS

NumBeats = 16
NumInstruments = 7
NumCellsX = NumBeats
NumCellsY = NumInstruments
TempoBps = 8
ButtonPadding = 20

BASS = 0
SNARE = 1
HITOM = 2
LOTOM = 3
OHIHAT = 4
CHIHAT = 5
CRASH = 6

-- GLOBALS

BeatGrid = {}
BeatAudio = {}

Levels = {
    { target =  500, instruments = { 1, 0, 1, 1, 0, 0, 0 } },
    { target = 1000, instruments = { 1, 1, 1, 1, 1, 1, 0 } },
    { target = 1500, instruments = { 2, 2, 2, 2, 2, 2, 0 } },
    { target = 2000, instruments = { 3, 3, 3, 3, 4, 4, 0 } },
    { target = 2500, instruments = { 4, 4, 4, 4, 6, 6, 0 } },
    { target = 999999, instruments = { 6, 6, 8, 8, 12, 12, 1}}
}

function LogNums(text, ...)
    print(string.format(text, ...))
end

function Empty(tab)
    return next(tab) == nil
end

function DestroyPhysicsObject(obj)
    obj.body:destroy()
end

function ResetWindowGlobals()
    WinWidth = love.graphics.getWidth()
    WinHeight = love.graphics.getHeight()
    GridHeight = WinHeight / 5
    GridTopLeftY = GridHeight * 4
    CellWidth = WinWidth / NumCellsX
    CellHeight = GridHeight / NumCellsY
    SideWallWidth = 50
    TopWallHeight = 50
    TopWallWidth = WinWidth / 2 - 20
    BotWallHeight = 50
    BotWallWidth = WinWidth / 2 - 80
end

function InitGlobals()
    Time = 0
    RemainingBalls = 25
    Score = 0
    Level = 1
    RestartButtonHover = false
    TimeSinceLevelUp = 999
    HiScore = 0
end

function InitDrums()
    BassDrum = {
        name = "bass",
        display_name = "KICK",
        x = WinWidth / 2,
        y = WinHeight * 0.75,
        time_since_hit = 999,
        colour = { r = 1, g = 0, b = 0 }
    }
    SnareDrum = {
        name = "snare",
        display_name = "SNARE",
        x = WinWidth / 2,
        y = WinHeight * 0.75,
        time_since_hit = 999,
        colour = { r = 1, g = 0.64, b = 0 }
    }
    HiTomDrum = {
        name = "hitom",
        display_name = "L-TOM",
        x = WinWidth / 7,
        y = WinHeight * 0.4,
        time_since_hit = 999,
        colour = { r = 0.6, g = 0.6, b = 0 }
    }
    LoTomDrum = {
        name = "lotom",
        display_name = "R-TOM",
        x = WinWidth - WinWidth / 7,
        y = WinHeight * 0.4,
        time_since_hit = 999,
        colour = { r = 1, g = 1, b = 0 }
    }
    OpenHiHatDrum = {
        name = "ohihat",
        display_name = "L-HIHAT",
        x = WinWidth / 5,
        y = WinHeight * 0.4,
        time_since_hit = 999,
        colour = { r = 0, g = 0.6, b = 0 }
    }
    ClosedHiHatDrum = {
        name = "chihat",
        display_name = "R-HIHAT",
        x = WinWidth - WinWidth / 5,
        y = WinHeight * 0.4,
        time_since_hit = 999,
        colour = { r = 0, g = 1, b = 0 }
    }
    CrashDrum = {
        name = "crash",
        display_name = "CRASH",
        x = WinWidth / 2,
        y = WinHeight * 0.8,
        time_since_hit = 999,
        colour = { r = 1, g = 0, b = 1 }
    }
    DrumsByIndex = {}
    DrumsByIndex[BASS] = BassDrum
    DrumsByIndex[SNARE] = SnareDrum
    DrumsByIndex[HITOM] = HiTomDrum
    DrumsByIndex[LOTOM] = LoTomDrum
    DrumsByIndex[OHIHAT] = OpenHiHatDrum
    DrumsByIndex[CHIHAT] = ClosedHiHatDrum
    DrumsByIndex[CRASH] = CrashDrum
end

function ResumeCoroutine(co, dt)
    local status = coroutine.status(co)
    if status == "suspended" then
        coroutine.resume(co, dt)
    end
end

function UpdateDrums(dt)
    if LeftHiHatCoroutine then
        ResumeCoroutine(LeftHiHatCoroutine, dt)
    end
    if RightHiHatCoroutine then
        ResumeCoroutine(RightHiHatCoroutine, dt)
    end
    BassDrum.time_since_hit = BassDrum.time_since_hit + dt
    SnareDrum.time_since_hit = SnareDrum.time_since_hit + dt
    LoTomDrum.time_since_hit = LoTomDrum.time_since_hit + dt
    HiTomDrum.time_since_hit = HiTomDrum.time_since_hit + dt
    OpenHiHatDrum.time_since_hit = OpenHiHatDrum.time_since_hit + dt
    ClosedHiHatDrum.time_since_hit = ClosedHiHatDrum.time_since_hit + dt
    CrashDrum.time_since_hit = CrashDrum.time_since_hit + dt
end

-- FUNCTIONS

function LoadAssets()
    BeatAudio = {
        bass = love.audio.newSource("assets/audio/kick-gritty.wav", "static"),
        snare = love.audio.newSource("assets/audio/snare-analog.wav", "static"),
        hitom = love.audio.newSource("assets/audio/tom-acoustic02.wav", "static"),
        lotom = love.audio.newSource("assets/audio/tom-acoustic01.wav", "static"),
        ohihat = love.audio.newSource("assets/audio/hihat-dist02.wav", "static"),
        chihat = love.audio.newSource("assets/audio/hihat-plain.wav", "static"),
        crash = love.audio.newSource("assets/audio/crash-acoustic.wav", "static")
    }
    HudFont = love.graphics.newFont(
        "assets/fonts/Kenney Rocket Square.ttf", 16)
    GridTickerFont = love.graphics.newFont(
        "assets/fonts/Kenney Rocket Square.ttf", 14)
    EndScreenFont = love.graphics.newFont(
        "assets/fonts/Kenney Rocket Square.ttf", 32)
    love.graphics.setFont(HudFont)
end

function InitPhysics()
    love.physics.setMeter(64) -- a meter is 64 pixels
    World = love.physics.newWorld(0, 6 * 64, true)
    Objects = {}
    InitBall()
    InitWalls()
    InitHiHats()
    Objects.snare = {}
end

function InitBall()
    Objects.ball = {}
    Objects.ball.body = love.physics.newBody(World, WinWidth / 2, 11, "dynamic")
    Objects.ball.shape = love.physics.newCircleShape(10)
    -- fixtures attach shapes to bodies.
    Objects.ball.fixture = love.physics.newFixture(Objects.ball.body, Objects.ball.shape, 1)
    Objects.ball.fixture:setRestitution(0.9) -- lets the ball bounce
end

function InitHiHats()
    Objects.left_hihat = {}
    Objects.right_hihat = {}

    local slope_width = BotWallWidth - SideWallWidth
    local slope_hypotenuse = math.sqrt(2 ^ 2 + slope_width ^ 2)
    local hihat_bar_width = slope_hypotenuse * 1.3
    local hihat_bar_height = 20
    local hihat_angle = math.atan((2 * BotWallHeight) / slope_width)
    HiHatCentreY = (
        (WinHeight * 0.8) - BotWallHeight * 2
    )

    -- left hihat
    LeftHiHatCentreX = (
        slope_width / 2 + SideWallWidth
    )
    Objects.left_hihat.body = love.physics.newBody(
        World, LeftHiHatCentreX, HiHatCentreY, "kinematic")
    Objects.left_hihat.body:setAngle(hihat_angle)
    Objects.left_hihat.shape = love.physics.newRectangleShape(
        hihat_bar_width, hihat_bar_height)
    Objects.left_hihat.fixture = love.physics.newFixture(
        Objects.left_hihat.body, Objects.left_hihat.shape)

    -- right hihat
    RightHiHatCentreX = (
        WinWidth - (slope_width / 2 + SideWallWidth)
    )
    Objects.right_hihat.body = love.physics.newBody(
        World, RightHiHatCentreX, HiHatCentreY, "kinematic")
    Objects.right_hihat.body:setAngle(2 * math.pi - hihat_angle)
    Objects.right_hihat.shape = love.physics.newRectangleShape(
        hihat_bar_width, hihat_bar_height)
    Objects.right_hihat.fixture = love.physics.newFixture(
        Objects.right_hihat.body, Objects.right_hihat.shape)
end

function InitWalls()
    Objects.walls = {}
    -- left and right straight walls
    table.insert(
        Objects.walls,
        InitRectangleWall(
            0, 0, SideWallWidth, WinHeight * 0.8))
    table.insert(
        Objects.walls,
        InitRectangleWall(
            WinWidth - SideWallWidth, 0, SideWallWidth, WinHeight * 0.8))
    -- left and right top walls
    table.insert(
        Objects.walls,
        InitRectangleWall(
            0, 0, TopWallWidth, TopWallHeight))
    table.insert(
        Objects.walls,
        InitRectangleWall(
            WinWidth - TopWallWidth, 0, TopWallWidth, TopWallHeight))
    -- left and right bottom walls
    table.insert(
        Objects.walls,
        InitRectangleWall(
            0, (WinHeight * 0.8) - BotWallHeight, BotWallWidth, BotWallHeight))
    table.insert(
        Objects.walls,
        InitRectangleWall(
            WinWidth - BotWallWidth,
            (WinHeight * 0.8) - BotWallHeight,
            BotWallWidth,
            BotWallHeight))
    -- left and right top slopes
    table.insert(
        Objects.walls,
        InitTriangleWall(
            SideWallWidth, TopWallHeight,
            SideWallWidth, 2 * TopWallHeight,
            TopWallWidth, TopWallHeight))
    table.insert(
        Objects.walls,
        InitTriangleWall(
            WinWidth - SideWallWidth, TopWallHeight,
            WinWidth - SideWallWidth, 2 * TopWallHeight,
            WinWidth - TopWallWidth, TopWallHeight))
    -- left and right bottom slopes
    table.insert(
        Objects.walls,
        InitTriangleWall(
            SideWallWidth, WinHeight * 0.8 - BotWallHeight,
            SideWallWidth, WinHeight * 0.8 - 3 * BotWallHeight,
            BotWallWidth, WinHeight * 0.8 - BotWallHeight))
    table.insert(
        Objects.walls,
        InitTriangleWall(
            WinWidth - SideWallWidth, WinHeight * 0.8 - BotWallHeight,
            WinWidth - SideWallWidth, WinHeight * 0.8 - 3 * BotWallHeight,
            WinWidth - BotWallWidth, WinHeight * 0.8 - BotWallHeight))
    -- wall to prevent ball going out of the top
    table.insert(
        Objects.walls,
        InitRectangleWall(
			0, 0, WinWidth, 1
		)
	)
end

function InitRectangleWall(x, y, w, h)
    local rect = {}
    local centre_x = x + (w / 2)
    local centre_y = y + (h / 2)
    rect.body = love.physics.newBody(World, centre_x, centre_y)
    rect.shape = love.physics.newRectangleShape(w, h)
    rect.fixture = love.physics.newFixture(rect.body, rect.shape)
    return rect
end

function InitTriangleWall(x1, y1, x2, y2, x3, y3)
    local tri = {}
    local centroid_x = (x1 + x2 + x3) / 3
    local centroid_y = (y1 + y2 + y3) / 3
    tri.body = love.physics.newBody(World, centroid_x, centroid_y)
    tri.shape = love.physics.newPolygonShape(
        x1 - centroid_x,
        y1 - centroid_y,
        x2 - centroid_x,
        y2 - centroid_y,
        x3 - centroid_x,
        y3 - centroid_y)
    tri.fixture = love.physics.newFixture(tri.body, tri.shape)
    return tri
end

function InitBeatGrid()
    for cell_x = 0, NumBeats do
        BeatGrid[cell_x] = {}
        for cell_y = 0, NumInstruments do
            BeatGrid[cell_x][cell_y] = {
                hover = false,
                on = false
            }
        end
    end
end

function ClearBeatGridHoverState()
    for cell_y = 0, NumInstruments do
        for cell_x = 0, NumBeats do
            BeatGrid[cell_x][cell_y].hover = false
        end
    end
end

function MouseCoordToGridCoord(mouse_x, mouse_y)
    -- transform mouse position to space in grid
    -- get position relative to grid top left
    local relative_mouse_y = mouse_y - GridTopLeftY
    -- convert x and y to cell coordinates
    local cell_x = math.floor(mouse_x / CellWidth)
    local cell_y = math.floor(relative_mouse_y / CellHeight)
    local mouse_in_grid = cell_x >= 0 and cell_x < NumCellsX and cell_y >= 0 and cell_y < NumCellsY
    return cell_x, cell_y, mouse_in_grid
end

function HandleBeatGridMouseHover()
    local mouse_x, mouse_y = love.mouse.getPosition()
    local cell_x, cell_y, mouse_in_grid = MouseCoordToGridCoord(mouse_x, mouse_y)
    if mouse_in_grid then
        BeatGrid[cell_x][cell_y].hover = true
    end
end

function GetAmountOfOnCellsForInstr(instr)
    local amount = 0
    for cell_x = 0, NumBeats do
        if BeatGrid[cell_x][instr].on then
            amount = amount + 1
        end
    end
    return amount
end

function HandleBeatGridMouseClick(mouse_x, mouse_y)
    local cell_x, cell_y, mouse_in_grid = MouseCoordToGridCoord(mouse_x, mouse_y)
    if mouse_in_grid then
        local is_on = BeatGrid[cell_x][cell_y].on
        if is_on then
            BeatGrid[cell_x][cell_y].on = false
            return
        end
        local amount_on = GetAmountOfOnCellsForInstr(cell_y)
        LogNums("%d %d %d", amount_on, Level, cell_y)
        if amount_on < Levels[Level].instruments[cell_y+1] then
            BeatGrid[cell_x][cell_y].on = true
        end
    end
end

function MouseIsOverRestartButton()
    local mouse_x, mouse_y = love.mouse.getPosition()
    local restart_text = "INSERT COIN"
    local button_top_left_x =
        WinWidth / 2 - HudFont:getWidth(restart_text) / 2 - ButtonPadding
    local button_top_left_y =
        WinHeight / 3 + EndScreenFont:getHeight()
    local button_width =
        2 * ButtonPadding + HudFont:getWidth(restart_text)
    local button_height =
        2 * ButtonPadding + HudFont:getHeight()

    return (
        mouse_x >= button_top_left_x and
        mouse_x <= button_top_left_x + button_width and
        mouse_y >= button_top_left_y and
        mouse_y <= button_top_left_y + button_height
    )
end

function UpdateBall(dt)
    -- if there's no ball, create it on the first beat of the bar
    local secs_to_cross_screen = NumBeats / TempoBps
    local time_bar_percent_this_frame = (Time % secs_to_cross_screen) / secs_to_cross_screen
    local time_bar_percent_last_frame = ((Time - dt) % secs_to_cross_screen) / secs_to_cross_screen
    local this_frame_beat = math.floor(time_bar_percent_this_frame * NumBeats)
    local last_frame_beat = math.floor(time_bar_percent_last_frame * NumBeats)
    if (
            not Objects.ball and
            this_frame_beat ~= last_frame_beat and
            this_frame_beat == 0
        ) then
        InitBall()
        RemainingBalls = RemainingBalls - 1
    end
    if not (Objects.ball) then return end
    -- if the ball drops off the bottom, destroy it
    if (
            Objects.ball.body:getY() > WinHeight * 0.8 or
            Objects.ball.body:getY() < 0 or
            Objects.ball.body:getX() < 0 or
            Objects.ball.body:getX() > WinWidth
        ) then
        DestroyPhysicsObject(Objects.ball)
        Objects.ball = nil
        Score = 0
    end
end

function UpdateScore(dt)
    TimeSinceLevelUp = TimeSinceLevelUp + dt
    if Objects.ball then
        Score = Score + 50 * dt
    end
	if Score > HiScore then
		HiScore = Score
	end
    if Score > Levels[Level].target then
        -- level up
        Level = Level + 1
        TimeSinceLevelUp = 0
        CrashDrum.time_since_hit = 0
    end
end

function ApplyBassDrumForce(x, y)
    local vec = {
        Objects.ball.body:getX() - x,
        Objects.ball.body:getY() - y
    }
    local mag = math.sqrt(vec[1] ^ 2 + vec[2] ^ 2)
    local unit_vec = {
        vec[1] / mag,
        vec[2] / mag
    }
    -- work out the force
    local max_force = 75
    local cutoff_percent = 0.2
    local dist_ratio = math.min(1, mag / (WinHeight * cutoff_percent))
    local force_mag = math.max(0, max_force * (1 - dist_ratio))
    local force_vec = {
        unit_vec[1] * force_mag,
        unit_vec[2] * force_mag
    }
    -- apply the force in a direction away from the drum
    LogNums("bass: (%f, %f)", force_vec[1], force_vec[2])
    Objects.ball.body:applyLinearImpulse(force_vec[1], force_vec[2])
end

function ApplyTomDrumForce(x)
    local ball_x = Objects.ball.body:getX()
    local ball_y = Objects.ball.body:getY()
    -- only apply force if the ball is out of the top spout
    if ball_y < TopWallHeight then
        return
    end
    local dist = ball_x - x
    local mag = math.abs(dist)
    local dir = dist / mag
    -- work out the force - should linearly drop
    local max_force = 25
    -- will cut off to 0 at 70% of screen width
    local cutoff_percent = 0.7
    -- distance as a percentage of 70% of the screen
    local dist_ratio = math.min(1, mag / (WinWidth * cutoff_percent))
    -- force scales inversely with the distance
    local force = math.max(0, max_force * (1 - dist_ratio)) * dir
    -- apply the force
    LogNums("tom: %f (%f, 0)", x, force)
    Objects.ball.body:applyLinearImpulse(force, 0)
end

function ApplySnareDrum(x, y)
    -- snare drum is a solid circle at the gutter
    -- that lasts for one beat
    Objects.snare = {}
    Objects.snare.body = love.physics.newBody(World, x, y)
    Objects.snare.shape = love.physics.newCircleShape(30)
    Objects.snare.fixture = love.physics.newFixture(Objects.snare.body, Objects.snare.shape, 1)
end

function ApplyLeftHiHat()
    local slope_width = BotWallWidth - SideWallWidth
    local angle = 2 * math.pi - (math.atan((2 * BotWallHeight) / slope_width) + math.pi)
    local dir = { x = -math.cos(angle), y = -math.sin(angle) }
    local force = 500
    local out_vel = { x = dir.x * force, y = dir.y * force }
    local in_vel = { x = -dir.x * force, y = -dir.y * force }
    local beat_secs = (NumBeats / TempoBps) / NumBeats
    LeftHiHatCoroutine = coroutine.create(
        function(dt)
            Objects.left_hihat.body:setPosition(LeftHiHatCentreX, HiHatCentreY)
            Objects.left_hihat.body:setLinearVelocity(out_vel.x, out_vel.y)
            local time = 0
            while time < beat_secs / 2 do
                time = time + dt
                coroutine.yield()
            end
            Objects.left_hihat.body:setLinearVelocity(in_vel.x, in_vel.y)
            while time < beat_secs do
                time = time + dt
                coroutine.yield()
            end
            Objects.left_hihat.body:setLinearVelocity(0, 0)
            Objects.left_hihat.body:setPosition(LeftHiHatCentreX, HiHatCentreY)
        end
    )
end

function ApplyRightHiHat()
    local slope_width = BotWallWidth - SideWallWidth
    local angle = 2 * math.pi - (math.atan((2 * BotWallHeight) / slope_width) + math.pi)
    local dir = { x = math.cos(angle), y = -math.sin(angle) }
    local force = 500
    local out_vel = { x = dir.x * force, y = dir.y * force }
    local in_vel = { x = -dir.x * force, y = -dir.y * force }
    local beat_secs = (NumBeats / TempoBps) / NumBeats
    RightHiHatCoroutine = coroutine.create(
        function(dt)
            Objects.right_hihat.body:setPosition(RightHiHatCentreX, HiHatCentreY)
            Objects.right_hihat.body:setLinearVelocity(out_vel.x, out_vel.y)
            local time = 0
            while time < beat_secs / 2 do
                time = time + dt
                coroutine.yield()
            end
            Objects.right_hihat.body:setLinearVelocity(in_vel.x, in_vel.y)
            while time < beat_secs do
                time = time + dt
                coroutine.yield()
            end
            Objects.right_hihat.body:setLinearVelocity(0, 0)
            Objects.right_hihat.body:setPosition(RightHiHatCentreX, HiHatCentreY)
        end
    )
end

function ApplyCrashDrumForce(y)
    local ball_y = Objects.ball.body:getY()
    -- only apply force if the ball is out of the top spout
    if ball_y < TopWallHeight then
        return
    end
    local dist = ball_y - y
    local mag = math.abs(dist)
    local dir = -1
    -- work out the force - should linearly drop
    local max_force = 50
    -- will cut off to 0 at 70% of screen width
    local cutoff_percent = 0.5
    -- distance as a percentage of 70% of the screen
    local dist_ratio = math.min(1, mag / (WinHeight * 0.8 * cutoff_percent))
    LogNums("crash | ball_y: %f | dist_ratio: %f", ball_y, dist_ratio)
    -- force scales inversely with the distance
    local force = math.max(0, max_force * (1 - dist_ratio)) * dir
    -- apply the force
    LogNums("crash: %f (0, %f)", y, force)
    Objects.ball.body:applyLinearImpulse(0, force)
end

function ActivateDrum(drum)
    drum.time_since_hit = 0
    if not(Objects.ball) then
        return
    end
    if drum.name == "bass" then
        ApplyBassDrumForce(drum.x, drum.y)
    elseif drum.name == "lotom" or drum.name == "hitom" then
        ApplyTomDrumForce(drum.x)
    elseif drum.name == "snare" then
        ApplySnareDrum(drum.x, drum.y)
    elseif drum.name == "ohihat" then
        ApplyLeftHiHat()
    elseif drum.name == "chihat" then
        ApplyRightHiHat()
    elseif drum.name == "crash" then
        ApplyCrashDrumForce(drum.y)
    end
end

function HandleDrumTrigger(dt)
    -- Only trigger the drum if the bar passed over the threshold
    -- in this frame.
    local secs_to_cross_screen = NumBeats / TempoBps
    local time_bar_percent_this_frame = (Time % secs_to_cross_screen) / secs_to_cross_screen
    local time_bar_percent_last_frame = ((Time - dt) % secs_to_cross_screen) / secs_to_cross_screen
    local this_frame_beat = math.floor(time_bar_percent_this_frame * NumBeats)
    local last_frame_beat = math.floor(time_bar_percent_last_frame * NumBeats)
    if this_frame_beat == last_frame_beat then
        -- beats are the same between frames = don't trigger the drums
        return
    end
    -- kill the snare drum if it was active
    if not (Empty(Objects.snare)) then
        DestroyPhysicsObject(Objects.snare)
        Objects.snare = {}
    end
    -- figure out which drums should sound
    local instruments = BeatGrid[this_frame_beat]

    if instruments[BASS].on then
        BeatAudio.bass:stop()
        BeatAudio.bass:play()
        ActivateDrum(BassDrum)
    end
    if instruments[SNARE].on then
        BeatAudio.snare:stop()
        BeatAudio.snare:play()
        ActivateDrum(SnareDrum)
    end
    if instruments[HITOM].on then
        BeatAudio.hitom:stop()
        BeatAudio.hitom:play()
        ActivateDrum(HiTomDrum)
    end
    if instruments[LOTOM].on then
        BeatAudio.lotom:stop()
        BeatAudio.lotom:play()
        ActivateDrum(LoTomDrum)
    end
    if instruments[OHIHAT].on then
        BeatAudio.ohihat:stop()
        BeatAudio.ohihat:play()
        ActivateDrum(OpenHiHatDrum)
    end
    if instruments[CHIHAT].on then
        BeatAudio.chihat:stop()
        BeatAudio.chihat:play()
        ActivateDrum(ClosedHiHatDrum)
    end
    if instruments[CRASH].on then
        BeatAudio.crash:stop()
        BeatAudio.crash:play()
        ActivateDrum(CrashDrum)
    end
end

function DrawGrid()
    -- draw background
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle(
        "fill", 0, WinHeight*0.8, WinWidth, WinHeight*0.2
    )
    -- draw tickers
    DrawGridTicker()
    -- draw hover/selected cells
    for cell_y = 0, NumCellsY do
        for cell_x = 0, NumCellsX do
            local top_left = {
                x = cell_x * CellWidth,
                y = cell_y * CellHeight + GridTopLeftY
            }
            local bg_colour = { r = 0, g = 0, b = 0, a = 0 }
            local cell = BeatGrid[cell_x][cell_y]
            if cell.hover then
                bg_colour = { r = 0.3, g = 0.3, b = 0.3, a = 1 }
            elseif cell.on
            then
                bg_colour = DrumsByIndex[cell_y].colour
                bg_colour.a = 1
            end
            -- background for the cell
            love.graphics.setColor(bg_colour.r, bg_colour.g, bg_colour.b, bg_colour.a)
            love.graphics.rectangle(
                "fill",
                top_left.x,
                top_left.y,
                CellWidth,
                CellHeight
            )
        end
    end
    -- draw grid lines
    local fg_colour = { r = 1, g = 1, b = 1, a = 1 }
    for cell_y = 0, NumCellsY do
        for cell_x = 0, NumCellsX do
            local top_left = {
                x = cell_x * CellWidth,
                y = cell_y * CellHeight + GridTopLeftY
            }
            -- outline for the cell
            love.graphics.setColor(fg_colour.r, fg_colour.g, fg_colour.b, fg_colour.a)
            love.graphics.rectangle(
                "line",
                top_left.x,
                top_left.y,
                CellWidth,
                CellHeight
            )
        end
    end
end

function DrawTimeBar()
    local secs_to_cross_screen = NumBeats / TempoBps
    local time_bar_percent = (Time % secs_to_cross_screen) / secs_to_cross_screen
    local time_bar_x = time_bar_percent * WinWidth
    local bar_colour = { red = 0.8, green = 0.0, blue = 0.0 }
    local default_line_width = love.graphics.getLineWidth()
    love.graphics.setLineWidth(4)
    love.graphics.setColor(bar_colour.red, bar_colour.green, bar_colour.blue)
    love.graphics.line(time_bar_x, GridTopLeftY, time_bar_x, WinHeight)
    love.graphics.setLineWidth(default_line_width)
end

function DrawBall()
    if not(Objects.ball) then
        return
    end
    love.graphics.setColor(0, 0, 1)
    love.graphics.circle(
        "fill",
        Objects.ball.body:getX(),
        Objects.ball.body:getY(),
        Objects.ball.shape:getRadius()
    )
end

function DrawWalls()
    love.graphics.setColor(0.5, 0.5, 0.8)
    for i, wall in ipairs(Objects.walls) do
        love.graphics.polygon(
            "fill",
            wall.body:getWorldPoints(wall.shape:getPoints())
        )
    end
end

function DrawBassDrumEffect()
    local max_time = (NumBeats / TempoBps) / (NumBeats / 4) -- 4 beats
    local diminish_factor = (max_time - BassDrum.time_since_hit) / max_time
    if diminish_factor < 0 then
        return
    end
    love.graphics.setColor(
        BassDrum.colour.r, BassDrum.colour.g, BassDrum.colour.b, diminish_factor)
    love.graphics.circle(
        "fill",
        BassDrum.x,
        BassDrum.y,
        100 * diminish_factor
    )
end

function DrawSnareDrumEffect()
    if Empty(Objects.snare) then
        return
    end
    local max_time = (NumBeats / TempoBps) / NumBeats -- 1 beats
    local diminish_factor = (max_time - SnareDrum.time_since_hit) / max_time
    if diminish_factor < 0 then
        return
    end
    love.graphics.setColor(
        SnareDrum.colour.r, SnareDrum.colour.g, SnareDrum.colour.b, diminish_factor)
    love.graphics.circle(
        "fill",
        Objects.snare.body:getX(),
        Objects.snare.body:getY(),
        Objects.snare.shape:getRadius()
    )
end

function DrawLeftTomDrumEffect()
    local max_time = (NumBeats / TempoBps) / (NumBeats / 4) -- 4 beats
    local diminish_factor = (max_time - HiTomDrum.time_since_hit) / max_time
    if diminish_factor < 0 then
        return
    end
    love.graphics.setColor(
        HiTomDrum.colour.r, HiTomDrum.colour.g, HiTomDrum.colour.b, diminish_factor)
    local bar_width = SideWallWidth * 2 + (1 - diminish_factor) * WinWidth * 0.4
    love.graphics.rectangle(
        "fill",
        0,
        0,
        bar_width,
        WinHeight * 0.8
    )
end

function DrawRightTomDrumEffect(drum)
    local max_time = (NumBeats / TempoBps) / (NumBeats / 4) -- 4 beats
    local diminish_factor = (max_time - LoTomDrum.time_since_hit) / max_time
    if diminish_factor < 0 then
        return
    end
    love.graphics.setColor(
        LoTomDrum.colour.r, LoTomDrum.colour.g, LoTomDrum.colour.b, diminish_factor)
    local bar_width = SideWallWidth * 2 + (1 - diminish_factor) * WinWidth * 0.4
    love.graphics.rectangle(
        "fill",
        WinWidth - bar_width,
        0,
        bar_width,
        WinHeight * 0.8
    )
end

function DrawHiHats()
    love.graphics.setColor(
        OpenHiHatDrum.colour.r, OpenHiHatDrum.colour.g, OpenHiHatDrum.colour.b, 1)
    love.graphics.polygon(
        "fill",
        Objects.left_hihat.body:getWorldPoints(
            Objects.left_hihat.shape:getPoints())
    )
    love.graphics.setColor(
        ClosedHiHatDrum.colour.r, ClosedHiHatDrum.colour.g, ClosedHiHatDrum.colour.b, 1)
    love.graphics.polygon(
        "fill",
        Objects.right_hihat.body:getWorldPoints(
            Objects.right_hihat.shape:getPoints())
    )
end

function RainbowCycle(t)
    local colour = { r = 0, g = 0, b = 0 }
    if t <= 1 / 6 then
        colour.r = 1
        colour.g = t * 6
        colour.b = 0
    elseif t <= 2 / 6 then
        colour.r = 1 - ((t - 1 / 6) * 6)
        colour.g = 1
        colour.b = 0
    elseif t <= 3 / 6 then
        colour.r = 0
        colour.g = 1
        colour.b = (t - 2 / 6) * 6
    elseif t <= 4 / 6 then
        colour.r = 0
        colour.g = 1 - ((t - 3 / 6) * 6)
        colour.b = 1
    elseif t <= 5 / 6 then
        colour.r = (t - 4 / 6) * 6
        colour.g = 0
        colour.b = 1
    else
        colour.r = 1
        colour.g = 0
        colour.b = 1 - ((t - 5 / 6) * 6)
    end
    return colour
end

function DrawCrashDrumEffect()
    local max_time = (NumBeats / TempoBps) / (NumBeats / 8) -- 8 beats
    local diminish_factor = (max_time - CrashDrum.time_since_hit) / max_time
    if diminish_factor < 0 then
        return
    end
    local colour = RainbowCycle((diminish_factor * 2) % 1)
    love.graphics.setColor(colour.r / 2, colour.g / 2, colour.b / 2, diminish_factor)
    local bar_height = BotWallHeight * 2 + (1 - diminish_factor) * WinHeight * 0.5
    love.graphics.rectangle(
        "fill",
        0,
        WinHeight * 0.8 - bar_height,
        WinWidth,
        bar_height
    )
end

function DrawHud()
    love.graphics.setColor(0.3, 0, 0, 1)
    -- show remaining balls
    love.graphics.print(
        string.format("%06d  CREDITS", math.max(0, RemainingBalls)),
        20,
        10
    )
    -- show current level
    love.graphics.print(
        string.format("%d/%d  LEVEL", Level, #Levels),
        20,
        10 + 5 + HudFont:getHeight()
    )
    -- show current score
    local score_hud = string.format("SCORE  %06d", Score)
    love.graphics.print(
        score_hud,
        WinWidth - 20 - HudFont:getWidth(score_hud),
        10
    )
    -- show target score
    local target_hud = string.format("TARGET %06d", Levels[Level].target)
    love.graphics.print(
        target_hud,
        WinWidth - 20 - HudFont:getWidth(target_hud),
        10 + 5 + HudFont:getHeight()
    )
end

function DrawGameOver()
    love.graphics.setColor(0.3, 0, 0, 0.8)
    love.graphics.setFont(EndScreenFont)
    love.graphics.rectangle(
        "fill",
        0,
        0,
        WinWidth,
        WinHeight
    )
    love.graphics.setColor(1, 0, 0, 1)
    local game_over_text = "NO CREDITS REMAINING"
    love.graphics.print(
        game_over_text,
        WinWidth / 2 - EndScreenFont:getWidth(game_over_text) / 2,
        WinHeight / 3 - EndScreenFont:getHeight() / 2
    )

    --display hiscore
    love.graphics.setColor(0, 1, 0, 1)
	love.graphics.setFont(HudFont)
    local hi_score_text = string.format("HISCORE: %d", HiScore)
	love.graphics.print(
        hi_score_text,
        WinWidth / 2 - HudFont:getWidth(hi_score_text) / 2,
        (WinHeight / 4 * 3) - HudFont:getHeight() / 2
    )
end

function DrawRestartButton()
    if RestartButtonHover then
        love.graphics.setColor(0, 1, 1, 1)
    else
        love.graphics.setColor(0, 0.3, 0.3, 1)
    end
    love.graphics.setFont(HudFont)
    local restart_text = "INSERT COIN"
    love.graphics.rectangle(
        "fill",
        WinWidth / 2 - HudFont:getWidth(restart_text) / 2 - ButtonPadding,
        WinHeight / 3 + EndScreenFont:getHeight(),
        2 * ButtonPadding + HudFont:getWidth(restart_text),
        2 * ButtonPadding + HudFont:getHeight()
    )
    if RestartButtonHover then
        love.graphics.setColor(0, 0.3, 0.3, 1)
    else
        love.graphics.setColor(0, 1, 1, 1)
    end
    love.graphics.print(
        restart_text,
        WinWidth / 2 - HudFont:getWidth(restart_text) / 2,
        WinHeight / 3 + EndScreenFont:getHeight() + ButtonPadding
    )
end

function DrawGridTickerForInstr(instr)
    local drum = DrumsByIndex[instr]
    local activations = GetAmountOfOnCellsForInstr(instr)
    local remaining = Levels[Level].instruments[instr+1] - activations
    if remaining == 0 then
        love.graphics.setColor(0.3, 0.3, 0.3, 1)
    else
        love.graphics.setColor(0.2, 0.2, 0.6, 1)
    end
    local ticker_text = string.format(
        "%s - %d - ", drum.display_name, remaining)
    local ticker_text_width = GridTickerFont:getWidth(ticker_text)
    local amount_of_repeats_needed = math.ceil(WinWidth / ticker_text_width)
    local full_ticker_text = string.rep(ticker_text, amount_of_repeats_needed + 2)
    -- track the text across the screen
    local secs_to_cross_screen = NumBeats / TempoBps
    local time_percent = (Time % secs_to_cross_screen) / secs_to_cross_screen
    local cell_height
    love.graphics.print(
        full_ticker_text,
        -ticker_text_width * time_percent,
        WinHeight * 0.8 +
        CellHeight / 2 +
        (CellHeight * instr) -
        (CellHeight / 2 - GridTickerFont:getHeight() / 2)
    )
end

function DrawGridTicker()
    love.graphics.setFont(GridTickerFont)
    for instr = 0, NumInstruments - 1 do
        DrawGridTickerForInstr(instr)
    end
end

function DrawLevelUp()
    local max_time = (NumBeats / TempoBps) / (NumBeats / 8) -- 8 beats
    local diminish_factor = (max_time - TimeSinceLevelUp) / max_time
    if diminish_factor < 0 then
        return
    end
    local colour = RainbowCycle((diminish_factor * 2) % 1)
    love.graphics.setColor(colour.r, colour.g, colour.b, diminish_factor)
    love.graphics.setFont(EndScreenFont)
    local text = "LEVEL UP!"
    if Level == #Levels then
        text = "YOU WIN! GO FOR HISCORE!"
		RemainingBalls = 0
    end
    local text_height = EndScreenFont:getHeight()
    local text_width = EndScreenFont:getWidth(text)
    love.graphics.print(
        text,
        WinWidth / 2 - text_width / 2,
        WinHeight * 0.3 - text_height / 2
    )
end

-- CALLBACKS

function love.load()
    LoadAssets()
    love.window.setMode(650, 1000)
	love.window.setTitle("Don't Drop The Beat")
    ResetWindowGlobals()
    InitGlobals()
    InitDrums()
    InitBeatGrid()
    InitPhysics()
end

function love.update(dt)
    if RemainingBalls < 0 then
        if MouseIsOverRestartButton() then
            RestartButtonHover = true
        else
            RestartButtonHover = false
        end
        return
    end
    ResetWindowGlobals()
    ClearBeatGridHoverState()
    HandleBeatGridMouseHover()
    Time = Time + dt
    UpdateDrums(dt)
    HandleDrumTrigger(dt)
    World:update(dt)
    UpdateBall(dt)
    UpdateScore(dt)
end

function love.draw()
    if RemainingBalls < 0 then
        DrawGameOver()
        DrawRestartButton()
        return
    end
    DrawBall()
    DrawBassDrumEffect()
    DrawSnareDrumEffect()
    DrawLeftTomDrumEffect()
    DrawRightTomDrumEffect()
    DrawCrashDrumEffect()
    DrawWalls()
    DrawHiHats()
    DrawGrid()
    DrawTimeBar()
    DrawHud()
    DrawLevelUp()
end

function love.mousereleased(x, y, button, istouch, presses)
    if RemainingBalls < 0 then
        if MouseIsOverRestartButton() then
            love.load()
        end
    else
        HandleBeatGridMouseClick(x, y)
    end
end
