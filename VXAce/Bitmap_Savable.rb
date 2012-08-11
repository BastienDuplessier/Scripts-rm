#==============================================================================
# ** DataManager
#------------------------------------------------------------------------------
#  Modification de init
#==============================================================================

module DataManager
  class << self
    #--------------------------------------------------------------------------
    # * alias
    #--------------------------------------------------------------------------
    alias picture_manager_init init
    #--------------------------------------------------------------------------
    # * Initialisation
    #--------------------------------------------------------------------------
    def init
      save_data([], "Data/Save_Bitmap.rvdata2") if $TEST and !File.exists?("Data/Save_Bitmap.rvdata2")
      picture_manager_init
    end
  end
end

#==============================================================================
# ** Font
#------------------------------------------------------------------------------
#  Ajout de Marshall dump et load
#  Ecrit par Yeyinde
#==============================================================================
class Font
  def marshal_dump;end
  def marshal_load(obj);end
end
#==============================================================================
# ** Bitmap
#------------------------------------------------------------------------------
#  Ajout de Marshall dump et load
#  Ecrit par Yeyinde
#==============================================================================

class Bitmap
  #--------------------------------------------------------------------------
  # * Win32API
  #--------------------------------------------------------------------------
  @@RtlMoveMemorySave = Win32API.new('kernel32','RtlMoveMemory','pii','i')
  @@RtlMoveMemoryLoad = Win32API.new('kernel32','RtlMoveMemory','ipi','i')
  #--------------------------------------------------------------------------
  # * Marshall dump
  #--------------------------------------------------------------------------
  def _dump(limit)
    data = "rgba"*width*height
    @@RtlMoveMemorySave.call(data,address,data.length)
    [width,height,Zlib::Deflate.deflate(data)].pack("LLa*")
  end

  #--------------------------------------------------------------------------
  # * Marshall load
  #--------------------------------------------------------------------------
  def self._load(str)
    w,h,zdata = str.unpack("LLa*")
    bitmap = new(w,h)
    @@RtlMoveMemoryLoad.call(bitmap.address,Zlib::Inflate.inflate(zdata),w*h*4)
    return bitmap
  end

  #--------------------------------------------------------------------------
  # * Récupère l'adresse
  #--------------------------------------------------------------------------
  def address
    buffer,ad="xxxx",object_id*2+16
    @@RtlMoveMemorySave.call(buffer,ad,4)
    ad=buffer.unpack("L")[0]+8
    @@RtlMoveMemorySave.call(buffer,ad,4)
    ad=buffer.unpack("L")[0]+16
    @@RtlMoveMemorySave.call(buffer,ad,4)
    return buffer.unpack("L")[0]
  end
end

#==============================================================================
# ** Screenshot_Manager
#------------------------------------------------------------------------------
#  API de capture d'écran
#==============================================================================

module Picture_Manager

  #==============================================================================
  # ** Saved_Bitmap
  #------------------------------------------------------------------------------
  #  Décris une image
  #==============================================================================

  class Saved_Bitmap
    #--------------------------------------------------------------------------
    # * Variables d'instances
    #--------------------------------------------------------------------------
    attr_accessor :bitmap, :name
    #--------------------------------------------------------------------------
    # * Constructeur
    #--------------------------------------------------------------------------
    def initialize(name, bitmap)
    @name, @bitmap = name, bitmap
    end
  end

  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  extend self

  #--------------------------------------------------------------------------
  # * Crée une capture d'écran
  #--------------------------------------------------------------------------
  def shot(name)
    return Saved_Bitmap.new(name, Graphics.snap_to_bitmap)
  end
  #--------------------------------------------------------------------------
  # * Sauve une image
  #--------------------------------------------------------------------------
  def save(saved_bitmap)
    unless saved_bitmap.is_a?(Saved_Bitmap)
      raise RuntimeError.new("Le fichier doit être une Saved_Bitmap") 
    end
    bmp_list = load_data("Data/Save_Bitmap.rvdata2")
    bmp_list ||= []
    bmp_list << saved_bitmap
    save_data(bmp_list, "Data/Save_Bitmap.rvdata2")
  end
  #--------------------------------------------------------------------------
  # * Retrouve une image
  #--------------------------------------------------------------------------
  def find(name)
    bmp_list = load_data("Data/Save_Bitmap.rvdata2")
    picture = bmp_list.find{|bmp| bmp.name == name}
    return picture.bitmap
  end
end