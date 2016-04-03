
import mersenne, math

type
  Property* = ref object of RootObj
    ## Represents a number that can vary 
    ## (higher than or lower than the original) 
    ## by a specified amount.
    startValue: float
    endValue:   float
    variance:   float

proc newProperty*(startValue: float, variance: float): Property =
  ## Creates a new Property instance
  
  result = new(Property)

  result.startValue = startValue
  result.variance   = variance

proc get*(property: Property, twister: var MersenneTwister): float =
  ## Returns a value that varies from the original 
  ## by up to the amount specified in the `variance` 
  ## field of `property`.
  let
    startVar:   float   = property.startValue * property.variance
    sign:       float   = if (twister.getNum mod 2) == 1: 1 else: -1
    startValue: float   = property.startValue + (sign * (float((twister.getNum * 1000) mod int(startVar * 1000)) / 1000))
  
  result = startValue

proc distance*(x1: float, y1: float, x2: float, y2: float): float =
  ## Returns the distance between two points.

  let 
    xDiff = x2-x1
    yDiff = y2-y1
    
  abs(sqrt(xDiff * xDiff + yDiff * yDiff))