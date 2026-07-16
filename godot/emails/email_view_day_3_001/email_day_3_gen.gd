extends EmailData
class_name EmailDay3

var opener = "Hi all,

We regularly evaluate our internal processes to ensure we are best positioned to meet the evolving demands of our customers and the industry.
At the end of the day, we need to get our ducks in a row.

That's why"

var closer = "

From all of us at the company, we cannot thank you enough for joining us on this journey.

You're welcome."

var day_3_dict = {
	## AI automatically cleans spills... but could create a new one
	1 : " the AI cleans spills now. No more wasting money on manual labor.",
	## AI is more accurate... but takes longer
	2 : " we've added workflow-enhancing technology, ensuring accuracy of orders.",
		## AI is less wasteful.. but not effecient
	3 : " we've increased the water to coffee beans ratio. More bank for our buck."
}

func _init():
	contents += opener	
	var chosen_buff = day_3_dict.keys().pick_random()
	contents += day_3_dict[chosen_buff]
	contents += closer
