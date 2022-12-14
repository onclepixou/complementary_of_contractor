require 'crmf'

module Gmi

	class Interval

	    attr_accessor :lb     # @return [Float] The lower bound of the interval
	    attr_accessor :ub     # @return [Float] The upper bound of the interval
	    attr_accessor :iota   # @return [Boolean] The iota component of the interval.

	    # Constructor
	    # @param lb_  [Float]
	    # @param ub_  [Float]
	    # @param iota_[Boolean]
	    def initialize(lb_, ub_, iota_)
	        # Return an empty set with iota set to false if at least one of the following conditions are met :
	        # lb or ub are not numeric
	        # iota is not a boolean
	        # lb or ub are nan
	        # bounds are not in correct order
			lb_ = lb_.to_f
			ub_ = ub_.to_f
	        if((!([true, false].include?(iota_))) || (lb_.nan?) || (ub_.nan?) || (lb_ > ub_) )
	            @lb = Float::NAN
	            @ub = Float::NAN
	            @iota = iota_
	            @empty = true
	        else
	            @lb = lb_
	            @ub = ub_
	            @iota = iota_
	            @empty = false
	        end
	    end

	    # The empty set, ∅
	    EMPTY_SET = Interval.new(1, 0, false)

	    # Iota, ∅ ∪ ⍳
	    IOTA = Interval.new(1, 0, true)
	
	    # All reals, [-∞, ∞]
	    ALL_REALS = Interval.new(-Float::INFINITY, Float::INFINITY, false)
	
	    # Positive reals, [0, ∞]
	    POS_REALS = Interval.new(0, Float::INFINITY, false)
	
	    # Negative reals, [-∞, 0]
	    NEG_REALS = Interval.new(-Float::INFINITY, 0, false)

	    # Returns _true_ if the "classic" part of the interval is empty.
	    # The _iota_ part is not concidered by this method.
	    # @return [Boolean]
	    def empty?
	        return @empty
	    end

	    # Returns _true_ if the "classic" part of the interval contains val.
	    # The _iota_ part is not concidered by this method.
	    # @return [Boolean]
	    def contains?(val)
	        return ((val >= lb) and (val <= ub))
	    end

	    # Returns the width of the "classic" part of the interval.
	    # @return [Float]
	    def width()
	        if(empty?)
	            return -Float::INFINITY
	        else
	            return (ub - lb)
	        end
	    end

	    # Returns the left part of the "classic" part of the interval.
	    # @return [Float]
	    def left()
	        if(empty?)
	            return EMPTY_SET
	        else
	            return Interval.new(lb, 0.5 * (lb + ub), iota )
	        end
	    end

	    # Returns the right part of the "classic" part of the interval.
	    # @return [Float]
	    def right()
	        if(empty?)
	            return EMPTY_SET
	        else
	            return Interval.new(0.5 * (lb + ub), ub, iota )
	        end
	    end

	    # Returns a string representation of the interval.
	    # If the iota part of the interval is empty ({iota} == _false_), it is not shown.
	    # If the iota part of the interval is not empty ({iota} == _true_), " ∪ ⍳" is appended.
	    # @return [String]
	    def to_s()
	        if(empty?)
	            s = "∅"
	        elsif(@lb == @ub)
	            s = "{#{@lb.to_f}}"
	        elsif((@lb == -Float::INFINITY) && (@ub == Float::INFINITY))
	            s = 'ℝ'
	        elsif ((@lb == -Float::INFINITY) && (@ub == 0))
	            s = 'ℝ₋'
	        elsif ((@lb == 0) && (@ub == Float::INFINITY))
	            s = 'ℝ₊'
	        else
	            s = "[#{@lb.to_f}, #{@ub.to_f}]"
	        end
	        s += ' ∪ ⍳' if @iota
	        return s
	    end

	    # used to allow external operations (+-*/) in both ways
	    def coerce(other)
	        return self, other
	    end
	
	    # Addition
	    # @param other [Interval, Numeric]
	    # @return [Interval]
	    def +(other)
	        if(other.is_a?(Interval))
	            if(empty? || other.empty?)
	                ret = ((iota) || (other.iota)) ? IOTA : EMPTY_SET
	                return ret
	            end
	            return Interval.new(CRMF.add_rd(@lb, other.lb), CRMF.add_ru(@ub, other.ub), (iota or other.iota))
	        else
				if(empty?)
					ret = iota ? IOTA : EMPTY_SET
					return ret
				end
	            other = other.to_f
	            return Interval.new(CRMF.add_rd(@lb, other), CRMF.add_ru(@ub, other), iota)
	        end
	    end

		# Addition
		# @param a [Interval, Numeric]
	    # @param b [Interval, Numeric]
	    # @return [Interval]
	    def self.add(a, b)
	        return a + b
	    end

	    # Subtraction
	    # @param other [Interval, Numeric]
	    # @return [Interval]
	    def -(other)
	        if(other.is_a?(Interval))
	            if(empty? || other.empty?)
	                ret = ((iota) || (other.iota)) ? IOTA : EMPTY_SET
	                return ret
	            end
	            return Interval.new(CRMF.sub_rd(@lb, other.ub), CRMF.sub_ru(@ub, other.lb), (iota or other.iota))
	        else
				if(empty?)
					ret = iota ? IOTA : EMPTY_SET
					return ret
				end
	            other = other.to_f
	            return Interval.new(CRMF.sub_rd(@lb, other), CRMF.sub_ru(@ub, other), iota)
	        end
	    end

		# Subtraction
		# @param a [Interval, Numeric]
	    # @param b [Interval, Numeric]
	    # @return [Interval]
	    def self.sub(a, b)
	        return a - b
	    end

	    # Unary -
	    # @return [Interval]
	    def -@
	      return -1 * self
	    end

	    # Multiplication
	    # @param other [Interval, Numeric]
	    # @return [Interval]
	    def *(other)
	        if(other.is_a?(Interval))
	            if(empty? || other.empty?)
	                ret = ((iota) || (other.iota)) ? IOTA : EMPTY_SET
	                return ret
	            end
	            candidates_lb = [CRMF.mul_rd(@lb, other.lb), CRMF.mul_rd(@lb, other.ub), CRMF.mul_rd(@ub, other.lb), CRMF.mul_rd(@ub, other.ub)]
	            candidates_ub = [CRMF.mul_ru(@lb, other.lb), CRMF.mul_ru(@lb, other.ub), CRMF.mul_ru(@ub, other.lb), CRMF.mul_ru(@ub, other.ub)]
	            return Interval.new(candidates_lb.min, candidates_ub.max, (iota or other.iota))
	        else
				if(empty?)
					ret = iota ? IOTA : EMPTY_SET
					return ret
				end
	            bounds = [CRMF.mul_rd(@lb, other), CRMF.mul_ru(@ub, other)]
	            return Interval.new(bounds.min, bounds.max, @iota)
	        end
	    end

		# Multiplication
		# @param a [Interval, Numeric]
	    # @param b [Interval, Numeric]
	    # @return [Interval]
	    def self.mul(a, b)
	        return a * b
	    end

	    # Division
	    # @param other [Interval, Numeric]
	    # @return [Interval]
	    def /(other)
	        if(other.is_a?(Interval))
	            if(empty? || other.empty? || other.contains?(0))
	                ret = ((iota) || (other.iota)) ? IOTA : EMPTY_SET
	                return ret
	            end
	            return self * Interval.new(CRMF.div_rd(1, other.ub), CRMF.div_ru(1, other.lb), (@iota or other.iota))
	        else
				if(empty?)
					ret = iota ? IOTA : EMPTY_SET
					return ret
				end
	            other = other.to_f
	            return Interval.new(CRMF.div_rd(lb, other), CRMF.div_ru(ub, other), (@iota))
	        end
	    end

		# Division
		# @param a [Interval, Numeric]
	    # @param b [Interval, Numeric]
	    # @return [Interval]
	    def self.div(a, b)
	        return a / b
	    end

	    # Intersection
	    # @param a [Interval]
	    # @param b [Interval]
	    # @return [Interval]
	    def self.intersection(a, b)
	        if(b.is_a?(Interval))
				res_iota = (a.iota && b.iota)
				return Interval.new(Float::NAN, Float::NAN, res_iota) if (a.empty? || (b.empty?))
	            res_lb = [a.lb, b.lb].max
	            res_ub = [a.ub, b.ub].min
	            return Interval.new(res_lb, res_ub, res_iota)
	        end
	    end

	    # Union
	    # @param a [Interval]
	    # @param b [Interval]
	    # @return [Interval]
	    def self.union(a, b)
	        if(b.is_a?(Interval))
				res_iota = (a.iota || b.iota)
	            return Interval.new(a.lb, a.ub, res_iota) if b.empty?
	            return Interval.new(b.lb, b.ub, res_iota) if a.empty?
	            res_lb = [a.lb, b.lb].min
	            res_ub = [a.ub, b.ub].max
	            return Interval.new(res_lb, res_ub, res_iota)
	        end
	    end

		# Square 
	    # @param x [Interval]
	    # @return [Interval]
	    def self.sqr(x)
	    	bounds = [CRMF.pow_rd(x.lb, 2), CRMF.pow_ru(x.ub, 2)]
			return Interval.new(Float::NAN, Float::NAN, x.iota) if x.empty?
			return Interval.new(0, bounds.max, x.iota) if x.contains?(0)
			return Interval.new(bounds.min, bounds.max, x.iota)
	    end

	    # Square Root
	    # @param x [Interval]
	    # @return [Interval]
	    def self.sqrt(x)
	        x_pos = intersection(x, POS_REALS)
			res_iota = (x.iota || (x.lb < 0))
			return Interval.new(Float::NAN, Float::NAN, res_iota) if x_pos.empty?
	      	if x_pos.contains?(0)
	        	return Interval.new(-CRMF.sqrt_rd(x_pos.ub), CRMF.sqrt_ru(x_pos.ub), res_iota)
	      	end
		    return Interval.new(CRMF.sqrt_rd(x_pos.lb), CRMF.sqrt_ru(x_pos.ub), res_iota)
	    end

		# Exp 
	    # @param x [Interval]
	    # @return [Interval]
		def self.exp(x)
			return Interval.new(CRMF.exp_rd(x.lb), CRMF.exp_ru(x.ub), x.iota);
		end

		# Log 
	    # @param x [Interval]
	    # @return [Interval]
	    def self.log(x)
			res_iota = (x.iota || (x.lb <= 0))
			return Interval.new(Float::NAN, Float::NAN, res_iota) if (x.ub < 0)
			return Interval.new(-Float::INFINITY, CRMF.log_ru(x.ub), res_iota) if x.contains?(0)
			return Interval.new(CRMF.log_rd(x.lb), CRMF.log_ru(x.ub), res_iota);
		end

		# Add Rev
		# return x,y such as z = x + y
	    # @param x [Interval]
		# @param y [Interval]
		# @param z [Interval]
	    # @return [Interval]
	    def self.add_rev(z, x, y)
	    	if(!z.iota)
	        	x = intersection(x, z - y)
	        	y = intersection(y, z - x)
	      	end
	      	return x, y
	    end

		# Add Rev 1
		# return x  such as z = x + y
	    # @param x [Interval]
		# @param y [Interval]
		# @param z [Interval]
	    # @return [Interval]
	    def self.add_rev1(z, x, y)
	    	return self.add_rev(z, x, y)[0]
	    end

		# Add Rev 2
		# return y  such as z = x + y
	    # @param x [Interval]
		# @param y [Interval]
		# @param z [Interval]
	    # @return [Interval]
	    def self.add_rev2(z, x, y)
	    	return self.add_rev(z, x, y)[1]
	    end

		# Sub Rev
		# return x,y such as z = x - y
	    # @param x [Interval]
		# @param y [Interval]
		# @param z [Interval]
	    def self.sub_rev(z, x, y)
	    	if(!z.iota)
	        	x = intersection(x, z + y)
	        	y = intersection(y, x - z)
	      	end
	      	return x, y
	    end

		# Sub Rev 1
		# return x  such as z = x - y
	    # @param x [Interval]
		# @param y [Interval]
		# @param z [Interval]
	    # @return [Interval]
	    def self.sub_rev1(z, x, y)
	    	return self.sub_rev(z, x, y)[0]
	    end

		# Sub Rev 2
		# return y  such as z = x - y
	    # @param x [Interval]
		# @param y [Interval]
		# @param z [Interval]
	    # @return [Interval]
	    def self.sub_rev2(z, x, y)
	    	return self.sub_rev(z, x, y)[1]
	    end

		# Mul Rev
		# return x,y such as z = x * y
	    # @param x [Interval]
		# @param y [Interval]
		# @param z [Interval]
	    # @return [Interval]
	    def self.mul_rev(z, x, y)
	    	if(!z.iota)
	        	x = intersection(x, z / y)
	        	y = intersection(y, z / x)
	      	end
	      	return x, y
	    end

		# Mul Rev 1
		# return x such as z = x * y
	    # @param x [Interval]
		# @param y [Interval]
		# @param z [Interval]
	    # @return [Interval]
	    def self.mul_rev1(z, x, y)
	    	return self.mul_rev(z, x, y)[0]
	    end

		# Mul Rev 2
		# return y such as z = x * y
	    # @param x [Interval]
		# @param y [Interval]
		# @param z [Interval]
	    # @return [Interval]
	    def self.mul_rev2(z, x, y)
	    	return self.mul_rev(z, x, y)[1]
	    end

		# Square Rev
		# return x such as y = sqr(x)
	    # @param x [Interval]
		# @param y [Interval]
	    # @return [Interval]
	    def self.sqr_rev(x, y) 
			return Interval.new(Float::NAN, Float::NAN, y.iota) if y.empty?
	    	x1 = intersection(x, NEG_REALS)
	    	x2 = intersection(x, POS_REALS)
	    	x1 = intersection(x1,  -sqrt(y))
	    	x2 = intersection(x2,   sqrt(y))
	    	xu = union(x1, x2)
	    	xc = intersection(xu, x)
	    	xc.iota = y.iota
	    	return xc
	    end

		# Square Root Rev
		# return x such as y = sqrt(x)
	    # @param x [Interval]
		# @param y [Interval]
	    # @return [Interval]
	    def self.sqrt_rev(x, y)
			return Interval.new(Float::NAN, Float::NAN, y.iota) if y.empty?
	      	r = sqr(y)
	      	if(y.iota)
	        	r_neg = union(r, NEG_REALS)
	        	r = Interval.new(r_neg.lb, r_neg.ub, true)
	      	end
	      	return intersection(r, x)
	    end

		# Exp Rev
		# return x such as y = exp(x)
	    # @param x [Interval]
		# @param y [Interval]
	    # @return [Interval]
	    def self.exp_rev(x, y)
			return Interval.new(Float::NAN, Float::NAN, y.iota) if y.empty?
	      	r = log(x)
	      	return Interval.new(r.lb, r.ub, (x.iota and r.iota))
	    end

		# Exp Rev
		# return x such as y = exp(x)
	    # @param x [Interval]
		# @param y [Interval]
	    # @return [Interval]
	    def self.log_rev(x, y) # y = log(x)
	    	return Interval.new(Float::NAN, Float::NAN, y.iota) if y.empty?
	      	r = exp(y)
	      	if(y.iota)
	        	r_neg = union(r, NEG_REALS)
	        	r = Interval.new(r_neg.lb, r_neg.ub, true)
	      	end
	      	return intersection(r, x)
	    end
	end
end