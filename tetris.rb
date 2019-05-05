# Controlling shapes
require "ruby2d"
require_relative "MyMap"
require_relative "Shape"
require_relative "Game"

cmd_args = ARGV

def DANCING_TRIANGLE
    set(title: "Hello Triangle", borderless:true, background: 'blue')
    tri = Triangle.new(x1: 320, y1:50,
                    x2: 540, y2:430,
                    x3:100, y3:430,
                    color: ['red', 'green', 'blue'])
    tick = 0
    x1 = tri.x1
    y23 = tri.y2 / 2
    dirx = diry = 1
    update do
        if tick % 10 == 0
            set background: 'random'
        end
        if(tick % 20 == 0)
            dirx *= -1
        end
        if(tick % 10 == 0)
            diry *= -1
        end
        tri.x1 = x1 + (tick % 100) * dirx
        tri.y2 = tri.y3 = y23 + (tick % 125) * diry
        tick += 1
    end
    show()
end

def SHAPES_PRINTED
    [Shape.new("O"), 
    Shape.new("I"),
    Shape.new("S"), 
    Shape.new("Z"), 
    Shape.new("L"), 
    Shape.new("J"),
    Shape.new("T")].each do |shape|
        shape.print
        puts("")
    end
end

def ROTATION_EXAMPLE
    t = Shape.new("T")
    t.print
    puts ""
    4.times do |_|
        t.rotate_clockwise
        t.print
        puts ""
    end
    4.times do |_|
        t.rotate_counterclockwise
        t.print
        puts ""
    end
end

def WEIRDLY_COLORED_SCREEN
    set(title: "Colors!!???", borderless:true, background: 'blue', width: 200, height: 200)
    m = MyMap.new(5, 5)
    m.clean_screen
    m.map_size_x.times do |x|
        m.map_size_y.times do |y|
           m.draw_block(x, y, 'random') 
        end
    end
    tick = 0
    update do
        if(tick % 2 == 0)
            m.clean_screen
            m.map_size_x.times do |x|
                m.map_size_y.times do |y|
                m.draw_block(x, y, 'random') 
                end
            end
        end 
        tick += 1
    end
    show()
end


def SMILEY
    set(title: "Smiley", borderless:true, background: 'blue', width: 200, height: 200)
    m = MyMap.new(5, 5)
    m.map[0][1] = 1
    m.map[0][3] = 1
    m.map[2][0] = 1
    m.map[3][1] = 1
    m.map[3][2] = 1
    m.map[3][3] = 1
    m.map[2][4] = 1
    m.draw_map
    m.print
    show()
end


def OUTLINED_MAP_OF_SIZE_5_5
    set(title: "Outlined tetris map 5,5", borderless:true, background: 'blue', width: 200, height: 200)
    m = MyMap.new(5, 5)
    s1 = Shape.new("L")
    s2 = Shape.new("J")
    s3 = Shape.new("J")
    s4 = Shape.new("L")

    s1.position[:x] = 0
    s1.position[:y] = 0
    s1.rotate_clockwise

    s2.position[:x] = 2
    s2.position[:y] = 0
    s2.rotate_counterclockwise

    s3.position[:x] = 0
    s3.position[:y] = 3
    s3.rotate_clockwise

    s4.position[:x] = 2
    s4.position[:y] = 3
    s4.rotate_counterclockwise

    m.print
    puts ""
    m.convert_shape_to_map(s1)
    m.convert_shape_to_map(s2)
    m.convert_shape_to_map(s3)
    m.convert_shape_to_map(s4)
    m.map[2][2] = 1
    m.draw_map('random')
    m.draw_shapes
    m.print
    show()
end

# DANCING_TRIANGLE()
# SHAPES_PRINTED()
# ROTATION_EXAMPLE()
# WEIRDLY_COLORED_SCREEN()
# SMILEY()
# OUTLINED_MAP_OF_SIZE_5_5()

p cmd_args.length
size_x = 10
size_y = 15
difficulty_step = 1.0/15
i = 0
while(i < cmd_args.length)
    arg = cmd_args[i]
    if(arg != nil)
        case(i)
        when 0
            size_x = arg.to_i
        when 1
            size_y = arg.to_i
        when 2
            difficulty_step = arg.to_i
        end
    end
    i += 1
end


game = Game.new
game.setup(size_x, size_y, difficulty_step)
game.start
