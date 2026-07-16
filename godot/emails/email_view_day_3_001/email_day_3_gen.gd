extends EmailData
class_name EmailDay3

var opener = "Hi all,

We regularly evaluate our internal processes to ensure we are best positioned to meet the evolving demands of our customers and the industry.
At the end of the day, we need to get our ducks in a row.

That's why"

var closer = "

From all of us at the company, we cannot thank you enough for joining us on this journey.

You're welcome."

# Nested type collections not supported, using new class 'AIImprovement' instead
var improvement_list: Array[AIImprovement] = [
	## AI automatically cleans spills... but more will happen
	AIImprovement.new(" the AI cleans spills now. No more wasting money on manual labor.",
	{
		'machine_chance_of_spill' : 0.1,
		'max_spills_per_shift' : 1.0
		# add stat / mechanic for ai to clean spills
	}),
	## AI is more accurate... but takes longer
	AIImprovement.new(" we've added workflow-enhancing technology, ensuring accuracy of orders.",
	{
		'machine_time_to_make_drink' : 0.5,
		'score_chances_3' : 0.1,
		'score_chances_neg3' : -0.1,
		'score_chances_1' : 0.25,
		'score_chances_neg1' : -0.25,
	}),
	## AI is less wasteful.. but not effecient
	AIImprovement.new(" we've increased the water to coffee beans ratio. More bank for our buck.",
	{
		'ingredients_per_order' : -5.0,
		'chance_of_machine_breaking' : 0.05
	})
]
func _init():
	contents += opener	
	var chosen_buff = improvement_list.pick_random()
	contents += chosen_buff.description
	# actually add the stats now
	for stat in chosen_buff.stat_bonuses:
		var current_stat = Stats.current.get(stat)
		if current_stat == null:
			push_error("email is trying to give a bonus to '%s' but that stat does not exist" % [stat])
		Stats.current.set(stat, current_stat + chosen_buff.stat_bonuses[stat])
	contents += closer
