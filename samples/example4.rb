#!/usr/bin/env ruby

require_relative '../lib/gmi'
require 'vibes-rb'

def c_fw(x1, x2, a, b)
    v1 = Gmi::Interval.sqr(x1)
    v2 = -a * v1
    v3 = Gmi::Interval.sqr(x2)
    v4 = v3 - 0.075
    v5 = Gmi::Interval.sqrt(v4)
    v6 = 1 + v2
    v7 = v6 + v5
    v8 = b * x1
    return [x1, x2, v1, v2, v3, v4, v5, v6, v7, v8]
end

def c_bw(vect, a, b)

    x1 = vect[0]
    x2 = vect[1]
    v1 = vect[2]
    v2 = vect[3]
    v3 = vect[4]
    v4 = vect[5]
    v5 = vect[6]
    v6 = vect[7]
    v7 = vect[8]
    v8 = vect[9]
    x1 = Gmi::Interval.intersection(x1, v8 * (1/b))
    v5, v6 = Gmi::Interval.add_rev(v7, v5, v6)
    v2 = v6 - 1
    v4 = Gmi::Interval.sqrt_rev(v4, v5)
    v3 = v4 + 0.075
    x2 = Gmi::Interval.intersection(Gmi::Interval.sqr_rev(x2, v3), x2)
    v1 = (-1/a) * v2
    x1 =  Gmi::Interval.intersection(Gmi::Interval.sqr_rev(x1, v1), x1)
    return x1, x2
end

def c5(x, y, a, b)

    vect1 = c_fw(x, y, a, b)
    vect2 = c_fw(vect1[8], vect1[9], a, b)
    vect3 = c_fw(vect2[8], vect2[9], a, b)
    vect4 = c_fw(vect3[8], vect3[9], a, b)
    vect5 = c_fw(vect4[8], vect4[9], a, b)

    invalid = (vect5[8].iota or vect5[9].iota)
    vect5[8].iota = false
    vect5[9].iota = false

    x4, y4 = c_bw(vect5, a, b)
    vect4[8] = x4
    vect4[9] = y4

    x3, y3 = c_bw(vect4, a, b)
    vect3[8] = x3
    vect3[9] = y3

    x2, y2 = c_bw(vect3, a, b)
    vect2[8] = x2
    vect2[9] = y2

    x1, y1 = c_bw(vect2, a, b)
    vect1[8] = x1
    vect1[9] = y1

    x0, y0 = c_bw(vect1, a, b)

    return  x0, y0, invalid
end

def sivia(f, entry)
    if(!entry.is_a? Gmi::Box)
        return
    end
	if (entry.width() < 0.01) 
        return
    end

    f.draw_box([entry.x.lb, entry.x.ub], [entry.y.lb, entry.y.ub], color:'blue[cyan]')
    x1c, x2c, invalid = c5(entry.x, entry.y, 1.4, 0.3 )

    if(x1c.empty? or x2c.empty?)
        return
    end

    if(invalid)
        f.draw_box([x1c.lb, x1c.ub], [x2c.lb, x2c.ub], color:'[yellow]')
        sivia(f, entry.left())
        sivia(f, entry.right())
    else
        f.draw_box([x1c.lb, x1c.ub], [x2c.lb, x2c.ub], color:'red[magenta]')
    end
end

a = Gmi::Box.new(Gmi::Interval.new(-5, 5, false), Gmi::Interval.new(-5, 5, false))
f = VIBes::Figure.new
f.width = 500
f.height = 500
sivia(f, a)
