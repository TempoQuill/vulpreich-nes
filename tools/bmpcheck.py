target_bit_depth = 4
with open("input.bmp", "rb") as binary_file:
	# first check the bit depth
	binary_file.seek(28, 0)
	single_byte = binary_file.read(1)

	# define the match, actual value depends on whether we're working with 4bpp, our
	# target bit depth is 4bpp because we can't be simply deinterleave bitplanes and
	# remove the bitmap header to generate CHR ROM
	def doth_bit_depths_match(single_byte, target_bit_depth):
		return single_byte == target_bit_depth
		try:
			depth_check = doth_bit_depths_match(target_bit_depth, single_byte)
			print("Target bit depth:", target_bit_depth)
			print("Bit depth match:", depth_check)
		except Exception as e:
			print("ERROR: Bit depth needs to be 4BPP. Index your colors down to 4 entries", e)