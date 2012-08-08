# Auteur : Grim 
# Permet de manipuler un bitmap ou il est facile d'appliquer des fusion 
# mais aussi des "défusion"
# ----------------------------------------------------------------------
# Exemple
# b = Bitmap_Mergeable.new(600, 700) ou b = Bitmap_Mergeable.new("UneImage")
# b.merge(1, "Image", 10, 10) => Ajouter true a la fin pour aligner en fonction du centre et non du coin haut gauche
# b.merge(2, "Image2", 15, 15)
# b.unmerge(1, 2) => L'image est identique qu'au début parce que les images 1 et 2 ont été enlevées. 

#==============================================================================
# ** Bitmap_Mergeable
#------------------------------------------------------------------------------
#  Easy way to merge bitmaps
#==============================================================================

class Bitmap_Mergeable < Bitmap

	#--------------------------------------------------------------------------
	# * Class variable
	#--------------------------------------------------------------------------
	attr_accessor :bitmaps, :raw

	#--------------------------------------------------------------------------
	# * Constructor
	#--------------------------------------------------------------------------
	def initialize(*args)
		raise RuntimeError.new("ARG's failing") if args.length == 0 || args.length > 2
		@args = args
		super(*@args)
		@raw = self.clone
		@bitmaps = []
	end

	#--------------------------------------------------------------------------
	# * Merge bitamp
	#--------------------------------------------------------------------------
	def merge(id, bmp, x, y, flag = false)
		bmp = (bmp.is_a?(Bitmap)) ? bmp : Bitmap.new(bmp)
		@bitmaps[id] = [bmp, x, y, flag]
		@bitmaps.compact!
		do_merge
	end

	#--------------------------------------------------------------------------
	# * Execute merging
	#--------------------------------------------------------------------------
	def do_merge
		@bitmaps.each do |bitmap|
			bmp = bitmap[0]
			x = bitmap[1]
			y = bitmap[2]
			flag = bitmap[3]
			x, y = x-bmp.width/2, y-bmp.height/2 if flag
			self.blt(x, y, bmp, Rect.new(0, 0, bmp.width, bmp.height))
		end
	end

	#--------------------------------------------------------------------------
	# * unmerde bitmap
	#--------------------------------------------------------------------------
	def unmerge(*ids)
		ids.each{|id| @bitmaps[id] = nil}
		@bitmaps.compact!
		restore
		do_merge
	end

	#--------------------------------------------------------------------------
	# * restore bitmap
	#--------------------------------------------------------------------------
	def restore
		self.blt(0, 0, @raw, Rect.new(0, 0, @raw.width, @raw.height))
	end

	#--------------------------------------------------------------------------
	# * clean bitmap
	#--------------------------------------------------------------------------
	def clean
		restore
		@bitmaps = []
	end

	#--------------------------------------------------------------------------
	# * visibility
	#--------------------------------------------------------------------------
	private :do_merge

end