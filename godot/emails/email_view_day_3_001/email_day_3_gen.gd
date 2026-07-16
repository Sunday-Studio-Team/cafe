extends EmailData
class_name EmailDay3

var opener = "Hi all,

We regularly evaluate our internal processes to ensure we are best positioned to meet the evolving demands of our customers and the industry.
At the end of the day, we need to get our ducks in a row.

That's why"

var closer = "

From all of us at the company, we cannot thank you enough for joining us on this journey.

 And you're welcome."

# Nested type collections not supported, using new class 'AIImprovement' instead
var improvement_list: Array[AIImprovement] = [
	## AI automatically cleans spills... but more will happen
	AIImprovement.new(" the machine's spills are smaller, less money wasted on manual labor.",
	{
		'machine_chance_of_spill' : 0.2,
		'max_spills_per_shift' : 1.0,
		'clean_spill_allowed_remaining' : 0.4
	}),
	## AI is more accurate... but takes longer
	AIImprovement.new(" we've added workflow-enhancing technology, ensuring accuracy of orders.",
	{
		'machine_time_to_make_drink' : 2.0,
		'score_chances_3' : 0.15,
		'score_chances_neg3' : -0.15,
		'score_chances_1' : 0.15,
		'score_chances_neg1' : -0.15,
	}),
	## AI is less wasteful.. but not effecient
	AIImprovement.new(" we've increased the water to coffee beans ratio. More bank for our buck.",
	{
		'ingredients_per_order' : -10.0,
		'chance_of_machine_breaking' : 0.15
	})
]
func _init():
	day_to_send = 3
	is_important = true
	sender_name = "Management"
	displayed_time = "7am"
	subject = "Important: Improvements"
	recipient_name = "Employee #000000"
	custom_email_view_packed_scene = load("res://emails/email_view_day_3_001/custom_email_view_day_3_001.tscn")
	contents += opener	
	var chosen_buff = improvement_list.pick_random()
	contents += chosen_buff.description
	Global.set('ai_improvement', chosen_buff)
	contents += closer
