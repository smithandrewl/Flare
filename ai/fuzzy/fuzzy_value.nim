import math
    
type FuzzyValue* = ref object of RootObj
  value: float

proc value*(fuzzyValue: FuzzyValue): float =
  result = fuzzyValue.value

proc `value=`*(fuzzyValue: FuzzyValue, value: float) =
  fuzzyValue.value = value

proc newFuzzyValue*(value: float): FuzzyValue =
  result = new(FuzzyValue)
  result.value = value

proc `$`*(fuzzyValue: FuzzyValue): string = 
  result = $(fuzzyValue.value)

proc `==`*(left: FuzzyValue, right: FuzzyValue): bool =
  result = left.value == right.value

proc `and`*(left: FuzzyValue, right: FuzzyValue): FuzzyValue =
  result = newFuzzyValue(min(left.value, right.value))

proc `or`*(left: FuzzyValue, right: FuzzyValue): FuzzyValue =
  result = newFuzzyValue(max(left.value, right.value))

proc `not`*(value: FuzzyValue): FuzzyValue =
  result = newFuzzyValue(1 - value.value)

proc implies*(left: FuzzyValue, right: FuzzyValue): FuzzyValue =
  let value = 
    if left.value <= right.value: 
      1.0 
    else: 
      right.value

  result = newFuzzyValue(value)

proc extremely*(fuzzyValue: FuzzyValue): FuzzyValue =
  let value = fuzzyValue.value

  result = newFuzzyValue(value * value * value)

proc very*(fuzzyValue: FuzzyValue): FuzzyValue =
  let value = fuzzyValue.value

  result = newFuzzyValue(value * value)

proc somewhat*(fuzzyValue: FuzzyValue): FuzzyValue =
  result = newFuzzyValue(sqrt(fuzzyValue.value)) 

proc slightly*(fuzzyValue: FuzzyValue): FuzzyValue =
  result = newFuzzyValue(pow(fuzzyValue.value, 1.0 / 3.0))
