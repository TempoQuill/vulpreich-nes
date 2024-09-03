target_start_offs = 154
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

	# Now check for a start offset of $9a
	binary_file.seek(10, 0)
	start_offset = binary_file.read(1)

	# Looked at one of the bitmaps on HxD, the header byte was 154 bytes long under 4BPP mode. It's not
	# exactly known why 154 specifically, though it could be just 64 bytes of whitespace starting after
	# the "BGRs" string followed by the four colors needed to convert the bitmap to the 2BPP CHR ROM
	def doth_offset_match(start_offset, target_start_offs)
		return start_offset == target_start_offs
		try:
			offset_check = doth_offset_match(target_start_offs, start_offset)
			print("Target start offset:", target_start_offs)
			print("Start offset match:", offset_check)
		except Exception as e:
			print("ERROR: Starting offset must be $9a. Image may have more than four colors.", e)
