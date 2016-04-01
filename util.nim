
import mersenne

type
  Property* = ref object of RootObj
    ## Represents a number that can vary 
    ## (higher than or lower than the original) 
    ## by a specified amount. 
    twister:    MersenneTwister
    startValue: float
    endValue:   float
    variance:   float

proc newProperty*(twister: MersenneTwister, startValue: float, endValue: float, variance: float): Property =
  ## Creates a new Property instance
  
  result = new(Property)

  result.twister    = twister
  result.startValue = startValue
  result.endValue   = endValue
  result.variance   = variance

proc get*(property: Property): (float, float) =
  ## Returns a value that varies from the original 
  ## by up to the amount specified in the `variance` 
  ## field of `property`.
  let
    startVar:   float   = property.startValue * property.variance
    endVar:     float   = property.endValue   * property.variance
    sign:       float   = if (property.twister.getNum mod 2) == 1: 1 else: -1
    startValue: float   = property.startValue + (sign * (float((property.twister.getNum * 1000) mod int(startVar * 1000)) / 1000))
    endValue:   float   = property.endValue   + (sign * (float((property.twister.getNum * 1000) mod int(endVar   * 1000)) / 100))

  result = (startValue, endValue)