require "ruby2d"

# * Setup game rules
# *    Make shapes fall till they hit bottom or collide, then integrate to map.
# *    If we cant spawn new shape without colliding directly after. End game
# * Create game loop
# * Prevent pillar of death
# * Take global args

class Game
    def start(no_window = false)
        @tick = 0
        Window.update do
            game_loop()
            draw_game()
        end

        if(!no_window) then Window.show() end
    end

    def setup(size_x = 10, size_y = 20, difficulty_steps = 1.0/15)
        Window.set(title: "Tetris", borderless: false, background: 'black', width: 400, height: 400)
        @map = MyMap.new(size_x, size_y)
        @updates_per_second = 2
        @fps = 60
        @current_shape = nil
        @rows_cleared  = 0
        @difficulty_steps = difficulty_steps

        Window.on(:key_down) do |event|
            # puts event.key
            if(@current_shape != nil)
                case event.key
                when 'up'
                    rotate_shape() 
                when 'left'
                    move_shape(-1)
                when 'right'
                    move_shape(1)
                when 'down'
                    full_drop()
                when 'keypad 1'
                    Window.close()
                end
            end
        end
    end

    def game_loop # TODO: Force shape to fall down. Check when row is filled, if so, Move rows above down one step. Game over if newly spawned shape is already colliding with map.
        if(@tick % (@fps / @updates_per_second).to_i == 0) # WARNING: Only works with whole numbers: @tick % (whole numbers)
            #Update start

            # Spawn new shape and check for game over
            if(@current_shape == nil)
                @current_shape = Shape.new("random")
                @current_shape.position[:x] = @map.map_size_x.to_i / 2.to_i

                # Game over check
                if(@map.check_collision_with_map(@current_shape))
                    game_over()
                end
            else
                did_fall = fall_or_die()
                if(!did_fall)
                    each_full_row() do |r|
                        clear_row(r)
                    end
                end
            end


            #Update end
        end
        @tick += 1
    end

    def draw_game
        @map.clean_screen
        @map.draw_map_outline()
        if(@current_shape != nil)
            #   COOL 3D EFFECT 
            # preview_shape = Shape.clone(@current_shape)
            # preview_shape.position[:x] += 1 
            # @map.draw_shape(preview_shape, 'blue')
            @map.draw_shape(@current_shape, 'red')
        end
        @map.draw_map()
    end

    def colliding_with_ground(shape)
        output = false
        shape.foreach_occupied_position() do |r, c|
            if(r >= @map.map_size_y) 
                output = true
            end
        end

        return output
    end

    def colliding_with_walls(shape)
        output = false
        shape.foreach_occupied_position() do |r, c|
            if(c < 0 || c >= @map.map_size_x)
                output = true
            end
        end

        return output
    end

    def each_full_row # Goes from top to bottom. Be careful of manipulating array
        r = 0
        while(r < @map.map.length)
            c = 0
            while(c < @map.map[r].length)
                if(@map.map[r][c] == 0)
                    break
                elsif(c == @map.map[r].length - 1)
                    yield(r)
                end
                c += 1
            end
            r += 1
        end
    end

    def clear_row(r)
        @map.map[r].map! do |container|
            container = 0
        end

        i = r
        while(i > 0)
            @map.map[i] = @map.map[i - 1].clone
            i -= 1
        end

        @rows_cleared += 1
        p @rows_cleared
        @updates_per_second += @difficulty_steps
    end

    def game_over
        puts "\nRows cleared: " + @rows_cleared.to_s
        puts "Speed " + @updates_per_second.to_s
        debug_map_size_colored(false)
    end

    def restart_game()
        Window.new()
        setup()
        start()
    end

    def full_drop()
        falling = true
        while(falling)
            falling = fall_or_die
        end

        each_full_row() do |r|
            clear_row(r)
        end
    end

    # Returns true on successful fall. False on death
    def fall_or_die
        # Check if shape can fall. Else turn shape into map
        output = false
        preview_shape = Shape.clone(@current_shape)
        preview_shape.position[:y] += 1 
        colliding_with_map = @map.check_collision_with_map(preview_shape)
        if(colliding_with_map || colliding_with_ground(preview_shape))
            @map.convert_shape_to_map(@current_shape) # TODO: DEBUG??? PILLAR OF DEATH
            @current_shape = nil
        else
            @current_shape.position[:y] += 1
            output = true
        end

        return output
    end

    def move_shape(vel)
        output = true
        preview_shape = Shape.clone(@current_shape)
        preview_shape.position[:x] += vel 
        colliding_with_map = @map.check_collision_with_map(preview_shape)
        if(colliding_with_map || colliding_with_walls(preview_shape))
            output = false
        else
            @current_shape.position[:x] += vel
        end

        return output
    end

    def rotate_shape(clockwise = true)
        output = true
        preview_shape = Shape.clone(@current_shape)
        if(clockwise)
            preview_shape.rotate_clockwise()
        else
            preview_shape.rotate_counterclockwise() 
        end

        colliding_with_map = @map.check_collision_with_map(preview_shape)
        if(colliding_with_map || colliding_with_walls(preview_shape) || colliding_with_ground(preview_shape))
            output = false
        else
            if(clockwise)
                @current_shape.rotate_clockwise()
            else
                @current_shape.rotate_counterclockwise() 
            end
        end

        return output
    end

    def debug_map_size_colored(outline = true)
        restart_game = false
        Window.on(:key_down) do |event|
            case event.key
            when 'keypad 1'
                Window.close()
            when 'keypad 0'
                # TODO: Restart game
            end
        end

        @tick = 0
        Window.update do
            if(@tick % 3 == 0)
                @map.clean_screen
                if(outline) then @map.draw_map_outline end
                @map.map_size_x.times do |x|
                    @map.map_size_y.times do |y|
                    @map.draw_block(x, y, 'random') 
                    end
                end
            end 
            @tick += 1
        end
    end
end