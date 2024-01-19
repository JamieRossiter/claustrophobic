extends Node

func find_closest(num, array):
	var best_match = null
	var least_diff = 2147483647;

	for number in array:
		var diff = abs(num - number)
		if(diff < least_diff):
			best_match = number
			least_diff = diff
			
	return best_match

func find_largest_vector(array: Array) -> Vector3:
	# Find largest x or z first, whichever is biggest
	var largest_x: float = 0.0;
	var largest_z: float = 0.0;
	for vector in array:
		if(largest_x < vector.x):
			largest_x = vector.x;
		if(largest_z < vector.z):
			largest_z = vector.z;
			
	# Find largest x or z next, depending on which one was bigger before
	var largest_x_secondary: float = 0.0;
	var largest_z_secondary: float = 0.0;
	for vector in array:
		if(largest_x_secondary < vector.x and vector.z == largest_z):
			largest_x_secondary = vector.x;
		if(largest_z_secondary < vector.z and vector.x == largest_x):
			largest_z_secondary = vector.z;
	
	# Determine the largest vector
	var largest_primary: float = 0.0;
	var largest_secondary: float = 0.0;
	if(largest_x > largest_z): 
		largest_primary = largest_x;
		largest_secondary = largest_z_secondary;
	else:
		largest_primary = largest_x_secondary;
		largest_secondary = largest_z;
		
	# Return Vector3 with y value at 0
	return Vector3(largest_primary, 0, largest_secondary);
