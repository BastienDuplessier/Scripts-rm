# Perform Blur by Hiino and Grim and Zeus81
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
    clone_bmp = self.clone
    8.times do |index|
      case index
      when 0; x, y = -decal, decal
      when 1; x, y = 0, decal
      when 2; x, y = 0, -decal
      when 3; x, y = -decal, -decal
      when 4; x, y = decal, decal
      when 5; x, y = -decal, 0
      when 6; x, y = decal, 0
      when 7; x, y = decal, -decal
      end
      fact_opacity = (index == 7) ? 255/2 : 255/(index+1)
      self.blt(x, y, clone_bmp, rect, fact_opacity)
    end
    clone_bmp.dispose
  end
 
end