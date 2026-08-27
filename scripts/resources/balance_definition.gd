## Global balance knobs that are not tied to one entity (SPEC-0010).
class_name BalanceDefinition
extends GameResource

## Fraction of total investment returned when selling a tower (SPEC-0010).
@export_range(0.0, 1.0) var sell_refund_ratio: float = 0.7

## STAR THRESHOLDS (SPEC-0011, data-driven since gap G-06 resolved):
## castle-health fraction required for three / two stars.
## Defaults preserve the historical 70%/35% policy so existing saves stay
## valid; the ONLY sanctioned tuning surface is resources/balance/*.tres.
@export_range(0.0, 1.0) var three_star_health_ratio: float = 0.7
@export_range(0.0, 1.0) var two_star_health_ratio: float = 0.35


func validate() -> Dictionary:
	var report := super.validate()
	var errors: PackedStringArray = report.errors
	if sell_refund_ratio < 0.0 or sell_refund_ratio > 1.0:
		errors.append("%s: sell_refund_ratio must be within 0.0..1.0" % id)
	if two_star_health_ratio < 0.0 or two_star_health_ratio > 1.0 \
			or three_star_health_ratio < 0.0 or three_star_health_ratio > 1.0:
		errors.append("%s: star ratios must be within 0.0..1.0" % id)
	if two_star_health_ratio >= three_star_health_ratio:
		errors.append("%s: two_star_health_ratio must be below three_star_health_ratio" % id)
	return report
