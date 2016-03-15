import mersenne

type
  Property* = ref object of RootObj
    twister:    MersenneTwister
    startValue: float
    endValue:   float
    variance:   float

proc newProperty*(twister: MersenneTwister, startValue: float, endValue: float, variance: float): Property =
  result = new(Property)

  result.twister    = twister
  result.startValue = startValue
  result.endValue   = endValue
  result.variance   = variance
  
proc get*(property: Property): (float, float) =
  let
    startVar:   float   = property.startValue * property.variance
    endVar:     float   = property.endValue   * property.variance
    sign:       float   = if (property.twister.getNum mod 2) == 1: 1 else: -1
    startValue: float   = property.startValue + (sign * (float((property.twister.getNum * 1000) mod int(startVar * 1000)) / 1000))
    endValue:   float   = property.endValue   + (sign * (float((property.twister.getNum * 1000) mod int(endVar   * 1000)) / 100))

  result = (startValue, endValue)