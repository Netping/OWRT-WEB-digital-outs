#
#	Lets define rules for seconds 0..999 and miliseconds: 0.001...0.999
#


MAIN		->	SECONDS ("." MILISECONDS):*


SECONDS		->	[0-9]					# 0..9
			|	[1-9] [0-9]				# 10..99
			|	[1-9] [0-9] [0-9]		# 100..999


MILISECONDS	->	[0-9]					# 0..9
			|	[0-9] [0-9]				# 10..99
			|	[0-9] [0-9] [1-9]		# 100..999