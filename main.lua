-- CONSTANTS

NumBeats = 16
NumInstruments = 7
NumCellsX = NumBeats
NumCellsY = NumInstruments

-- GLOBALS

BeatGrid = {}

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

function HandleBeatGridMouseHover()
   local mouse_x, mouse_y = love.mouse.getPosition()
   -- transform mouse position to space in grid
   -- get position relative to grid top left
   local relative_mouse_y = mouse_y - GridTopLeftY
   -- if relative y is less than 0, it's not in the grid
   if relative_mouse_y < 0 then
	  return
   end
   -- convert x and y to cell coordinates
   local cell_x = math.floor(mouse_x / CellWidth)
   local cell_y = math.floor(relative_mouse_y / CellHeight)
   if cell_x >= 0 and cell_x < NumCellsX and cell_y >= 0 and cell_y < NumCellsY then
	  BeatGrid[cell_y][cell_x].hover = true
   end
end

function DrawGrid()
   for cell_y = 0, NumCellsY do
	  for cell_x = 0, NumCellsX do
		 local top_left = {
			x = cell_x * CellWidth,
			y = cell_y * CellHeight + GridTopLeftY
		 }
		 local fill_type = "line"
		 local cell = BeatGrid[cell_y][cell_x]
		 if cell.hover or cell.on then
--			print(string.format("%d,%d: %s %s", cell_x, cell_y, cell.hover, cell.on))
			fill_type = "fill"
		 end
		 love.graphics.rectangle(
			fill_type,
			top_left.x,
			top_left.y,
			CellWidth,
			CellHeight
		 )
	  end
   end
end

-- CALLBACKS

function love.load()
   ResetWindowGlobals()
   InitBeatGrid()
   print(BeatGrid)
end

function love.update(dt)
   ResetWindowGlobals()
   ClearBeatGridHoverState()
   HandleBeatGridMouseHover()
end

function love.draw()
   DrawGrid()
end
