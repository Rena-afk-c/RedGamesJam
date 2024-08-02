extends Node

#Global handeling of seeds/currency
var total_collected_seeds:int = 0

func collect_seeds(amt:int):
	total_collected_seeds += amt
