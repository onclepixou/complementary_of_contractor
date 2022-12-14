module Gmi

    class Box

        attr_accessor :x   # @return [Interval] The x component of the box
        attr_accessor :y   # @return [Interval] The y component of the box

        def initialize(x_, y_)
            if(!x_.is_a?(Gmi::Interval) or !y_.is_a?(Gmi::Interval))
                raise ArgumentError.new("Bad arguments")
            end
            @x = x_
            @y = y_
        end

        def to_s()
            s = "(" + x.to_s + ") x (" + y.to_s + ")"
            return s
        end

        def width()
            if(x.empty? || y.empty?)
                return -Float::INFINITY
            else
                return [x.width(), y.width()].max()
            end
        end

        def left()
            if(x.width() > y.width())
                return Box.new(x.left(), y)
            else
                return Box.new(x, y.left())
            end
        end

        def right()
            if(x.width() > y.width())
                return Box.new(x.right(), y)
            else
                return Box.new(x, y.right())
            end
        end
    end
end