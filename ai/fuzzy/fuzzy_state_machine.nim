import fuzzy_state, sequtils

type FuzzyStateMachine*[T] = ref object of RootObj
  states: seq[FuzzyState[T]]

proc newFuzzyStateMachine*[T](): FuzzyStateMachine[T] =
    result = new(FuzzyStateMachine[T])
    result.states = @[]

proc newFuzzyStateMachine*[T](states: seq[FuzzyState[T]]): FuzzyStateMachine[T] =
    result = new(FuzzyStateMachine[T])
    result.states = states

proc update*[T](fuzzyStateMachine: FuzzyStateMachine[T], data: T) =
    for state in fuzzyStateMachine.states:
        state.execute(data)
