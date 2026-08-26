## Global balance knobs that are not tied to one entity (SPEC-0010).
class_name BalanceDefinition
extends GameResource

## Fraction of total investment returned when selling a tower (SPEC-0010).
@export_range(0.0, 1.0) var sell_refund_ratio: float = 0.7


func validate() -> Dictionary:
	var report := super.validate()
	var errors: PackedStringArray = report.errors
	if sell_refund_ratio < 0.0 or sell_refund_ratio > 1.0:
		errors.append("%s: sell_refund_ratio must be within 0.0..1.0" % id)
	return report
