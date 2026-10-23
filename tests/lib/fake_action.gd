extends UtilityAction
## Test double: returns fixed scores/need levels and counts runs.

var fixed_score : float = 0.0
var fixed_need : float = 0.0
var finish : bool = false
var committed : bool = false
var runs : int = 0

func score() -> float:
	return fixed_score

func need_ratio() -> float:
	return fixed_need

func run(_delta: float) -> bool:
	runs += 1
	return finish

func is_committed() -> bool:
	return committed
