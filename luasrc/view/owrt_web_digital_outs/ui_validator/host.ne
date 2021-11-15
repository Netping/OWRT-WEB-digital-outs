
#
# Lets describe the rules for IP address and port, e.g: 192.168.0.1:90
#

MAIN 			-> IP

IP 				-> NUMBER "." NUMBER "." NUMBER "." NUMBER

NUMBER 			-> From_0_to_255

From_0_to_255 	-> 	[0-9] 					# 0..9
					| [1-9] [0-9] 			# 10..99
					| "1" [0-9] [0-9] 		# 100.. 199
					| "2" [0-5] [0-5]		# 200..255