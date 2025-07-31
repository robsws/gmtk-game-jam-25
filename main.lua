function love.load()
   
end

function love.update(dt)

end

function draw_grid()
   cells_x = 17
   cells_y = 7
   win_width = love.graphics.getWidth()
   win_height = love.graphics.getHeight()
   grid_height = win_height / 4
   grid_top_left_y = (win_height / 4) * 3
   cell_width = win_width / cells_x
   cell_height = grid_height / cells_y
   for cell_y=0,cells_y do
	  for cell_x=0,cells_x do
		 top_left = {
			x = cell_x * cell_width,
			y = cell_y * cell_height + grid_top_left_y
		 }
		 love.graphics.rectangle(
			"line",
			top_left.x,
			top_left.y,
			cell_width,
			cell_height
		 )
	  end
   end
end

function love.draw()
   draw_grid()
end
