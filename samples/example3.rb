#!/usr/bin/env ruby

require_relative '../lib/gmi'
require 'vibes-rb'

def inDomain(res, inside)
    if(inside)
        return Gmi::Interval.intersection(res, Gmi::Interval::POS_REALS)
    else
        return Gmi::Interval.intersection(res, Gmi::Interval::NEG_REALS)
    end
end

def contractor(x1, x2, inside)

    a = Gmi::Interval.log(x1)
    b = x2 - a
    b = inDomain(b, inside)
    x2= Gmi::Interval.sub_rev1(b, x2, a)
    a = Gmi::Interval.sub_rev2(b, x2, a)
    x1 = Gmi::Interval.log_rev(x1, a)
    return x1, x2
end

def sivia(f, entry)
    if(!entry.is_a? Gmi::Box)
        return
    end
	if (entry.width() < 0.01) 
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
