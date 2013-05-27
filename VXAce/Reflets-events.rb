# Reflets dynamique par s4suk3 Plagié de Fabien (merci pour l'aide etoo)
# Réécrit par Grim
# Aidé par Fabien, Zangther et Nuki

# Attention, pour fonctionner les tiles qui doivent refleter quelque chose 
# doivent être légèrement transparent ! (en plus avec le parallax ça rend mieux :D)

# Pour qu'un event n'ait pas de reflet il faut mettre un ! devant son nom
# Pour qu'un event ait un reflet qui n'ondule pas il faut un ? devant son nom

#==============================================================================
# ** Reflect_Config
#------------------------------------------------------------------------------
#  Permet la configuration des reflets du héros
#==============================================================================
module Reflect_Config
  extend self
  #--------------------------------------------------------------------------
  # * Liste des configuration du héros
  #--------------------------------------------------------------------------
  def maps_behaviour
    list = {}
    # Liste des maps avec un comportemment spécifique pour le héros
    # Par exemple: list[3] = :fix donnera un reflet non ondulant au héros sur la map 3
    # Liste des possibilités:
    # - :ondulate -> ondule légèrement
    # - :fix -> n'ondule pas
    # - :none -> pas de reflet
    list[1] = :none

    # Retourne la liste de comportemments
    list
  end
end

#==============================================================================
# ** Game_Event
#------------------------------------------------------------------------------
#  This class handles events. Functions include event page switching via
# condition determinants and running parallel process events. Used within the
# Game_Map class.
#==============================================================================

class Game_Event
  #--------------------------------------------------------------------------
  # * Return the event name
  #--------------------------------------------------------------------------
  def name
    @event.name
  end 
end
#==============================================================================
# ** Sprite_Character
#------------------------------------------------------------------------------
#  This sprite is used to display characters. It observes a instance of the
# Game_Character class and automatically changes sprite conditions.
#==============================================================================

class Sprite_Character
  #--------------------------------------------------------------------------
  # * Public instance variable
  #--------------------------------------------------------------------------
  attr_accessor :type
  #--------------------------------------------------------------------------
  # * Alias
  #--------------------------------------------------------------------------
  alias vx_initialize initialize
  alias vx_update update
  alias vx_dispose dispose
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     viewport  : viewport
  #     character : character (Game_Character)
  #--------------------------------------------------------------------------
  def initialize(viewport, character = nil)
    @type = :ondulate
    if character && character.instance_of?(Game_Event)
      @type = :none if character.name =~ /^!/
      @type = :fix if character.name =~ /^\$/
    end
    if character.instance_of?(Game_Player)
      if Reflect_Config.maps_behaviour.key?($game_map.map_id)
        @type = Reflect_Config.maps_behaviour[$game_map.map_id]
      end
    end
    vx_initialize(viewport, character) 
    @reflect = Sprite_Reflect.new(viewport, character, 2, @type) if @type != :none
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    @reflect.update if @reflect
    vx_update
  end
end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    @reflect.dispose if @reflect
    vx_dispose
  end
  
  
#==============================================================================
# ** Sprite_Reflect
#------------------------------------------------------------------------------
#==============================================================================

class Sprite_Reflect < Sprite_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     viewport  : viewport
  #     character : character (Game_Character)
  #--------------------------------------------------------------------------
  def initialize(viewport, chara, dir, type)
    super(viewport)
    @type = type
    self.z = -50
    @character = chara
    @dir = dir
    @blur = false
    if @type == :ondulate
      self.wave_amp = 2 
      self.wave_length = 300  
    end
    update
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    update_bitmap
    self.visible = (not @character.transparent)
    update_src_rect
    if @dir == 2
      self.angle = 180 
    elsif @dir == 4
      self.angle = 90 
    elsif @dir == 6
      self.angle = 270
    elsif @dir == 8
      self.angle = 0
    end
    self.x = @character.screen_x
    self.y = @character.screen_y
    self.opacity = 230
    self.blend_type = @character.blend_type
    self.bush_depth = @character.bush_depth
    #self.tone = Tone.new(100, 100, 200, 80)
    if @character.animation_id != 0
      animation = $data_animations[@character.animation_id]
      start_animation(animation)
      @character.animation_id = 0
    end
  end
  #--------------------------------------------------------------------------
  # * Get tile set image that includes the designated tile
  #     tile_id : Tile ID
  #--------------------------------------------------------------------------
  def tileset_bitmap(tile_id)
    Cache.tileset($game_map.tileset.tileset_names[5 + tile_id / 256])
  end
  #--------------------------------------------------------------------------
  # * Update Transfer Origin Bitmap
  #--------------------------------------------------------------------------
  def update_bitmap
    if @tile_id != @character.tile_id or
       @character_name != @character.character_name or
       @character_index != @character.character_index
      @tile_id = @character.tile_id
      @character_name = @character.character_name
      @character_index = @character.character_index
      if @tile_id > 0
        sx = (@tile_id / 128 % 2 * 8 + @tile_id % 8) * 32;
        sy = @tile_id % 256 / 8 % 16 * 32;
        self.bitmap = tileset_bitmap(@tile_id)
        self.src_rect.set(sx, sy, 32, 32)
        self.ox = 16
        self.oy = 32
      else
        self.bitmap = Cache.character(@character_name).clone
        unless @blur
          self.bitmap.blur
          @blur = true
        end
        sign = @character_name[/^[\!\$]./]
        if sign != nil and sign.include?('$')
          @cw = bitmap.width / 3
          @ch = bitmap.height / 4
        else
          @cw = bitmap.width / 12
          @ch = bitmap.height / 8
        end
        self.ox = @cw / 2
        self.oy = @ch - ((@character_name == "$tree") ? 24 : 0)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Update Transfer Origin Rectangle
  #--------------------------------------------------------------------------
  def update_src_rect
    if @tile_id == 0
     if @dir == 2
      direction = 2 if @character.direction == 2
      direction = 6 if @character.direction == 4
      direction = 4 if @character.direction == 6
      direction = 8 if @character.direction == 8
    elsif @dir == 4
      direction = 4 if @character.direction == 2
      direction = 2 if @character.direction == 4
      direction = 8 if @character.direction == 6
      direction = 6 if @character.direction == 8
    elsif @dir == 6
      direction = 6 if @character.direction == 2
      direction = 8 if @character.direction == 4
      direction = 2 if @character.direction == 6
      direction = 4 if @character.direction == 8
    elsif @dir == 8
      direction = 8 if @character.direction == 2
      direction = 4 if @character.direction == 4
      direction = 6 if @character.direction == 6
      direction = 2 if @character.direction == 8
    end
      index = @character.character_index
      pattern = @character.pattern < 3 ? @character.pattern : 1
      sx = (index % 4 * 3 + pattern) * @cw
      sy = (index / 4 * 4 + (direction - 2) / 2) * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
    end
  end

end
