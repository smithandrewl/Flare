
type FuzzyState*[T] = ref object of RootObj
  action:     proc(data:T, membership: float)
  membership: proc(data:T): float
  name:       string

proc name*[T](fuzzyState: FuzzyState[T]): string =
  result = fuzzyState.name

proc `name=`*[T](fuzzyState: FuzzyState[T], name: string) =
    fuzzyState.name = name

proc newFuzzyState*[T](
    name:       string, 
    membership: proc(data:T): float, 
    action:     proc(data:T, membership: float)
): FuzzyState[T] =
    result = new(FuzzyState)
    result.name       = name
    result.membership = membership
    result.action     = action

proc execute*[T](fuzzyState: FuzzyState[T], data: T) =
    fuzzyState.action(data, fuzzyState.membership(data))
    