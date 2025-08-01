-- CONSTANTS

NumBeats = 16
NumInstruments = 7
NumCellsX = NumBeats
NumCellsY = NumInstruments
TempoBps = 8

BASS = 0
SNARE = 1
HITOM = 2
LOTOM = 3
OHIHAT = 4
CHIHAT = 5
CRASH = 6

-- GLOBALS

BeatGrid = {}
Time = 0
BeatAudio = {}

function ResetWindowGlobals()
    WinWidth = love.graphics.getWidth()
    WinHeight = love.graphics.getHeight()
    GridHeight = WinHeight / 5
    GridTopLeftY = GridHeight * 4
    CellWidth = WinWidth / NumCellsX
    CellHeight = GridHeight / NumCellsY
end

function InitDrums()
   BassDrum = {
        x = WinWidth / 2,
        y = WinHeight * 0.7,
        force = 3,
		time_since_hit = 999
    }
    SnareDrum = {
        x = WinWidth / 2,
        y = WinHeight * 0.4,
        force = 2,
		time_since_hit = 999
    }
    HiTomDrum = {
        x = WinWidth / 5,
        y = WinHeight * 0.7,
        force = 2,
		time_since_hit = 999
    }
    LoTomDrum = {
        x = WinWidth - WinWidth / 5,
        y = WinHeight * 0.7,
        force = 2,
		time_since_hit = 999
    }
    OpenHiHatDrum = {
        x = WinWidth / 5,
        y = WinHeight * 0.4,
        force = 1,
		time_since_hit = 999
    }
    ClosedHiHatDrum = {
        x = WinWidth - WinWidth / 5,
        y = WinHeight * 0.4,
        force = 1,
		time_since_hit = 999
    }
    CrashDrum = {
        x = WinWidth / 2,
        y = WinHeight * 0.4,
        force = 4,
		time_since_hit = 999
    }
end

function UpdateDrums(dt)
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
end

function InitPhysics()
    love.physics.setMeter(64) -- a meter is 64 pixels
    World = love.physics.newWorld(0, 6 * 64, true)
    Objects = {}
    InitBall()
	InitWalls()
end

function InitBall()
    Objects.ball = {}
    Objects.ball.body = love.physics.newBody(World, WinWidth / 2, 0, "dynamic")
    Objects.ball.shape = love.physics.newCircleShape(10)
    -- fixtures attach shapes to bodies.
    Objects.ball.fixture = love.physics.newFixture(Objects.ball.body, Objects.ball.shape, 1)
    Objects.ball.fixture:setRestitution(0.9) -- lets the ball bounce
end

function InitWalls()
   Objects.walls = {}
   local side_wall_width = 50
   local top_wall_height = 50
   local top_wall_width = WinWidth/2 - 20
   local bot_wall_height = 50
   local bot_wall_width = WinWidth/2 - 80
   -- left and right straight walls
   table.insert(
	  Objects.walls,
	  InitRectangleWall(
		 0, 0, side_wall_width, WinHeight * 0.8))
   table.insert(
	  Objects.walls,
	  InitRectangleWall(
		 WinWidth - side_wall_width, 0, side_wall_width, WinHeight*0.8))
   -- left and right top walls
   table.insert(
	  Objects.walls,
	  InitRectangleWall(
		 0, 0, top_wall_width, top_wall_height))
   table.insert(
	  Objects.walls,
	  InitRectangleWall(
		 WinWidth - top_wall_width, 0, top_wall_width, top_wall_height))
   -- left and right bottom walls
   table.insert(
	  Objects.walls,
	  InitRectangleWall(
		 0, (WinHeight*0.8) - bot_wall_height, bot_wall_width, bot_wall_height))
   table.insert(
	  Objects.walls,
	  InitRectangleWall(
		 WinWidth - bot_wall_width,
		 (WinHeight * 0.8) - bot_wall_height,
		 bot_wall_width,
		 bot_wall_height))
   -- left and right top slopes
   table.insert(
	  Objects.walls,
	  InitTriangleWall(
		 side_wall_width, top_wall_height,
		 side_wall_width, 2 * top_wall_height,
		 top_wall_width, top_wall_height))
   table.insert(
	  Objects.walls,
	  InitTriangleWall(
		 WinWidth - side_wall_width, top_wall_height,
		 WinWidth - side_wall_width, 2 * top_wall_height,
		 WinWidth - top_wall_width, top_wall_height))
   -- left and right bottom slopes
   table.insert(
	  Objects.walls,
	  InitTriangleWall(
		 side_wall_width, WinHeight*0.8 - bot_wall_height,
		 side_wall_width, WinHeight*0.8 - 3 * bot_wall_height,
		 bot_wall_width, WinHeight*0.8 - bot_wall_height))
   table.insert(
	  Objects.walls,
	  InitTriangleWall(
		 WinWidth - side_wall_width, WinHeight*0.8 - bot_wall_height,
		 WinWidth - side_wall_width, WinHeight*0.8 - 3 * bot_wall_height,
		 WinWidth - bot_wall_width, WinHeight * 0.8 - bot_wall_height))
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
   for cell_x = 0,NumBeats do
	  BeatGrid[cell_x] = {}
	  for cell_y = 0,NumInstruments do
		 BeatGrid[cell_x][cell_y] = {
			hover = false,
			on = false
		 }
	  end
   end
end

function ClearBeatGridHoverState()
   for cell_y=0,NumInstruments do
	  for cell_x=0,NumBeats do
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

function HandleBeatGridMouseClick(mouse_x, mouse_y)
    local cell_x, cell_y, mouse_in_grid = MouseCoordToGridCoord(mouse_x, mouse_y)
    if mouse_in_grid then
        local is_on = BeatGrid[cell_x][cell_y].on
        if is_on then
            BeatGrid[cell_x][cell_y].on = false
        else
            BeatGrid[cell_x][cell_y].on = true
        end
    end
end

function UpdateBall()
    -- if the ball drops off the bottom, put it back at the top
    if Objects.ball.body:getY() > WinHeight * 0.8 then
	   Objects.ball.body:release()
	   InitBall()
    end
end

function ActivateDrum(drum)
   drum.time_since_hit = 0
   -- drums don't affect balls below them
   if Objects.ball.body:getY() < drum.y then
	  return
   end
   -- work out how close the ball is to the drum point
   local vec = {
	  Objects.ball.body:getX() - drum.x,
	  Objects.ball.body:getY() - drum.y
   }
   local mag = math.sqrt(vec[1] ^ 2 + vec[2] ^ 2)
   local unit_vec = {
	  vec[1] / mag,
	  vec[2] / mag
   }
   -- work out the force - should be inverse square of distance
   local force = 1/(mag^2) * drum.force * 1000
   -- apply the force in a direction away from the drum
   Objects.ball.body:applyLinearImpulse(unit_vec[1] * force, unit_vec[2] * force)
end

function HandleDrumTrigger(dt)
   -- Only trigger the drum if the bar passed over the threshold
   -- in this frame.
   local secs_to_cross_screen = NumBeats / TempoBps
   local time_bar_percent_this_frame = (Time % secs_to_cross_screen) / secs_to_cross_screen
   local time_bar_percent_last_frame = ((Time-dt) % secs_to_cross_screen) / secs_to_cross_screen
   local this_frame_beat = math.floor(time_bar_percent_this_frame * NumBeats)
   local last_frame_beat = math.floor(time_bar_percent_last_frame * NumBeats)
   if this_frame_beat == last_frame_beat then
	  -- beats are the same between frames = don't trigger the drums
	  return
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
    for cell_y = 0, NumCellsY do
        for cell_x = 0, NumCellsX do
            local top_left = {
                x = cell_x * CellWidth,
                y = cell_y * CellHeight + GridTopLeftY
            }
            local bg_colour = { red = 0, green = 0, blue = 0 }
            local fg_colour = { red = 1, green = 1, blue = 1 }
            local cell = BeatGrid[cell_x][cell_y]
            if cell.hover then
                bg_colour = { red = 0.3, green = 0.3, blue = 0.3 }
            elseif cell.on
            then
                bg_colour = { red = 0, green = 0.8, blue = 0.7 }
            end
            -- background for the cell
            love.graphics.setColor(bg_colour.red, bg_colour.green, bg_colour.blue, 1)
            love.graphics.rectangle(
                "fill",
                top_left.x,
                top_left.y,
                CellWidth,
                CellHeight
            )
            -- outline for the cell
            love.graphics.setColor(fg_colour.red, fg_colour.green, fg_colour.blue, 1)
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

function DrawDrum(drum)
   local max_time = (NumBeats / TempoBps) / (NumBeats/4) -- 4 beats
   local diminish_factor = (max_time - drum.time_since_hit) / max_time
   if diminish_factor < 0 then
	  return
   end
   love.graphics.setColor(1, 0, 0, diminish_factor)
   love.graphics.circle(
	  "fill",
	  drum.x,
	  drum.y,
	  drum.force * 20 * diminish_factor
   )
end

function DrawDrums()
    DrawDrum(BassDrum)
    DrawDrum(SnareDrum)
    DrawDrum(LoTomDrum)
    DrawDrum(HiTomDrum)
    DrawDrum(OpenHiHatDrum)
    DrawDrum(ClosedHiHatDrum)
    DrawDrum(CrashDrum)
end

-- CALLBACKS

function love.load()
   LoadAssets()
   love.window.setMode(650, 1000)
   ResetWindowGlobals()
   InitDrums()
   InitBeatGrid()
   InitPhysics()
end

function love.update(dt)
   ResetWindowGlobals()
   ClearBeatGridHoverState()
   HandleBeatGridMouseHover()
   Time = Time + dt
   UpdateDrums(dt)
   HandleDrumTrigger(dt)
   World:update(dt)
   UpdateBall()
end

function love.draw()
   DrawGrid()
   DrawTimeBar()
   DrawBall()
   DrawWalls()
   DrawDrums()
end

function love.mousereleased(x, y, button, istouch, presses)
   HandleBeatGridMouseClick(x, y)
end
