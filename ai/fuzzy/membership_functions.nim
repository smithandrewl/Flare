import math

# Based on the article http://www.bindichen.co.uk/post/AI/fuzzy-inference-membership-function.html
proc max(left: float, right: float): float =
  if left > right:
    result = left
  else:
    result = right

proc min(left: float, right: float): float =
  if left < right:
    result = left
  else:
    result = right

proc triangular(value: float, left: float, center: float, right: float): float =
  result = max(
    min(
      (value - left)  / (center - left),
      (right - value) / (right  - center)
    ),
    0.0
  )

proc trapezoidal(value: float, leftBottom: float, leftTop: float, rightTop: float, rightBottom: float): float =
  result = max(
    min(
      1,
      min(
        (value - leftBottom)  / (leftTop - leftBottom),
        (rightBottom - value) / (rightBottom - rightTop)
      )
    ),
    0
  )

# Gaussian function is probably not correct
proc gaussian(value: float, middle: float, width: float): float =
  var exp = (value - middle) / width;
  exp = exp * exp;

  result = pow(E, -1 * (exp / 2))

proc gaussianRight(value: float, cap: float, width: float): float =
  if value > cap:
    result = 1.0
  else:
    result = gaussian(value, cap, width)

proc gaussianLeft(value: float, min: float, width: float): float =
  if value < min:
    result = 1.0
  else:
    result = gaussian(value, min, width)

proc generalizedBell(value: float, a: float, b: float, c: float): float =
  # full exp is 1/ (1 + pow(abs((value - c) / (a)), 2 * b))
  var exp = value;

  exp -= c
  exp /= a
  exp =  abs(exp)
  exp =  pow(exp, 2*b)
  exp += 1
  exp =  1/exp

  result = exp


