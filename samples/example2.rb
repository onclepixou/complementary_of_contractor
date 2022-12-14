#!/usr/bin/env ruby

require_relative '../lib/gmi'
require 'vibes-rb'

def inDomain(res, inside)
    if(inside)
        return Gmi::Interval.intersection(res, Gmi::Interval.new(1, 2, false))
    else
        res_1 = Gmi::Interval.intersection(res, Gmi::Interval.new(-Float::INFINITY, 1, false))
        res_2 = Gmi::Interval.intersection(res, Gmi::Interval.new(2, Float::INFINITY, false))
        return Gmi::Interval.union(res_1, res_2)
    end
end

def contractor(x1, x2, inside)

    a = x1 + x2
    b = Gmi::Interval.sqrt(a)
    c = x2 + b
    c = inDomain(c, inside)
    x2, b = Gmi::Interval.add_rev(c, x2, b)
    a = Gmi::Interval.sqrt_rev(a, b)
    x1, x2 = Gmi::Interval.add_rev(a, x1, x2)
    return x1, x2
end

def sivia(f, entry)
    if(!entry.is_a? Gmi::Box)
        return
    end
	if (entry.width() < 0.1) 
        return
    end
    if(entry.x.empty? or entry.y.empty?)
        return
    end

	f.draw_box([entry.x.lb, entry.x.ub], [entry.y.lb, entry.y.ub], color:'blue[cyan]')
	
    entry.x, entry.y = contractor(entry.x, entry.y, true)
    if(entry.x.empty? or entry.y.empty?)
        return
    end
	f.draw_box([entry.x.lb, entry.x.ub], [entry.y.lb, entry.y.ub], color:'red[magenta]')

	entry.x, entry.y = contractor(entry.x, entry.y, false)
    if(entry.x.empty? or entry.y.empty?)
        return
    end
	f.draw_box([entry.x.lb, entry.x.ub], [entry.y.lb, entry.y.ub], color:'[yellow]')

	sivia(f, entry.left())
	sivia(f, entry.right())
end

a = Gmi::Box.new(Gmi::Interval.new(-10,10, false), Gmi::Interval.new(-10,10, false))
f = VIBes::Figure.new
f.width = 500
f.height = 500
sivia(f, a)
