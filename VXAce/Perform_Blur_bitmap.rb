# Perform Blur by Hiino and Grim
#==============================================================================
# ** Bitmap
#------------------------------------------------------------------------------
# Add the perform_blur function
#==============================================================================

class Bitmap
	#--------------------------------------------------------------------------
	# * Blur a bitmap
	#--------------------------------------------------------------------------
	def perform_blur(decal)
		calc_pos = ->(_decal, i) do 
			result = [-decal, _decal]
			case i
			when 1; result = [0, _decal]
			when 2; result = [0, -_decal]
			when 3; result = [-_decal, -_decal]
			when 4; result = [_decal, _decal]
			when 5; result = [-_decal, 0]
			when 6; result = [_decal, 0]
			when 7; result = [_decal, -_decal]
			end
			return *result
		end.curry.(decal)
		bmp_table = Array.new(8, self.clone)
		(0...8).each do |index|
			curr_bmp = bmp_table[index]
			x, y = calc_pos.(index)
			rect = Rect.new(0, 0, self.width, self.height)
			fact_opacity = (index == 8) ? 255/2 : 255/(index+1)
			self.blt(x, y, curr_bmp, rect, fact_opacity)
		end
	end
end