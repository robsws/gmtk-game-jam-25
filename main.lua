-- CONSTANTS

NumBeats = 16
NumInstruments = 7
NumCellsX = NumBeats
NumCellsY = NumInstruments
TempoBps = 2

-- GLOBALS

BeatGrid = {}
Time = 0

function ResetWindowGlobals()
   WinWidth = love.graphics.getWidth()
   WinHeight = love.graphics.getHeight()
   GridHeight = WinHeight / 4
   GridTopLeftY = (WinHeight / 4) * 3
   CellWidth = WinWidth / NumCellsX
   CellHeight = GridHeight / NumCellsY
end

-- FUNCTIONS

-- beat grid

function InitBeatGrid()
   for cell_y=0,NumInstruments do
	  BeatGrid[cell_y] = {}
	  for cell_x=0,NumBeats do
		 BeatGrid[cell_y][cell_x] = {
			hover = false,
			on = false
		 }
	  end
   end
end

function ClearBeatGridHoverState()
   for cell_y=0,NumInstruments do
	  for cell_x=0,NumBeats do
		 BeatGrid[cell_y][cell_x].hover = false
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
        BeatGrid[cell_y][cell_x].hover = true
    end
end

function HandleBeatGridMouseClick(mouse_x, mouse_y)
   local cell_x, cell_y, mouse_in_grid = MouseCoordToGridCoord(mouse_x, mouse_y)
   if mouse_in_grid then
	  local is_on = BeatGrid[cell_y][cell_x].on
	  if is_on then
		 BeatGrid[cell_y][cell_x].on = false
	  else
		 BeatGrid[cell_y][cell_x].on = true
	  end
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
            local cell = BeatGrid[cell_y][cell_x]
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

-- CALLBACKS

function love.load()
   ResetWindowGlobals()
   InitBeatGrid()
end

function love.update(dt)
   ResetWindowGlobals()
   ClearBeatGridHoverState()
   HandleBeatGridMouseHover()
   Time = Time + dt
end

function love.draw()
   DrawGrid()
   DrawTimeBar()
end

function love.mousereleased(x, y, button, istouch, presses)
   HandleBeatGridMouseClick(x, y)
end
