import membership_functions, fuzzy_value

type FuzzyVariable = ref object of RootObj
  value:     float
  weights:   seq[float]
  fullWidth: float
  halfWidth: float
  min:       float
  span:      float
  max:       float

proc newFuzzyVariable*(min: float, max: float, weights: seq[float]): FuzzyVariable =
    result = new(FuzzyVariable)

    result.weights   = weights
    result.min       = min
    result.max       = max
    result.span      = max - min
    result.halfWidth = result.span / 7
    result.halfWidth = result.halfWidth + result.halfWidth * 0.2

proc newFuzzyVariable*(min: float, max: float): FuzzyVariable =
    result = newFuzzyVariable(min, max, @[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0])
  
proc value*(variable: FuzzyVariable): float =
    result = variable.value

proc `value=`*(variable: FuzzyVariable, value: float) =
    variable.value = value

# grade
proc veryLow*(variable: FuzzyVariable): FuzzyValue =
    result = newFuzzyValue(gaussianLeft(variable.value, variable.min, variable.halfWidth / 2))

proc gaussianA*(variable: FuzzyVariable, index: int): float =
    result = gaussian(variable.value, variable.min + ((float(index) + 0.5) * variable.halfWidth) , variable.halfWidth / 2)

proc low*(variable: FuzzyVariable): FuzzyValue =
    result = newFuzzyValue(variable.gaussianA(1))

proc almostLow*(variable: FuzzyVariable): FuzzyValue =
    result = newFuzzyValue(variable.gaussianA(2))

proc middle*(variable: FuzzyVariable): FuzzyValue =
    result = newFuzzyValue(variable.gaussianA(3))

proc almostHigh*(variable: FuzzyVariable): FuzzyValue =
    result = newFuzzyValue(variable.gaussianA(4))

proc high*(variable: FuzzyVariable): FuzzyValue =
    result = newFuzzyValue(variable.gaussianA(5))

# rgrade
proc veryHigh*(variable: FuzzyVariable): FuzzyValue =
    result = newFuzzyValue(gaussianRight(variable.value, variable.max, variable.halfWidth / 2))

proc fuzzify*(variable: FuzzyVariable, crispInput: float) =
    variable.value = crispInput

proc defuzzify*(variable: FuzzyVariable, weights: seq[float]): float =
  result = 
    variable.veryLow.value    * variable.weights[0] +
    variable.low.value        * variable.weights[1] +
    variable.almostLow.value  * variable.weights[2] +
    variable.middle.value     * variable.weights[3] +
    variable.almostHigh.value * variable.weights[4] +
    variable.high.value       * variable.weights[5] +
    variable.veryHigh.value   * variable.weights[6] 

proc defuzzify*(variable: FuzzyVariable): float =
    result = defuzzify(variable, variable.weights)