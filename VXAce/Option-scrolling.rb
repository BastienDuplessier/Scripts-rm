# FunkyScrolling par s4suk3 et Raho(tsé tung)

module ScrollingConfig
    DEFAULT_SPEED = 2
    DEFAULT_TYPE = :not
    extend self
    def map_notscrollable
        # Ajouter ici les map non scrollables
        []
    end
end

#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  This class handles maps. It includes scrolling and passage determination
# functions. The instance of this class is referenced by $game_map.
#==============================================================================

class Game_Map
    #--------------------------------------------------------------------------
    # * Alias
    #--------------------------------------------------------------------------
    alias scroll_set_display_pos set_display_pos
    #--------------------------------------------------------------------------
    # * Public Instance Variables
    #--------------------------------------------------------------------------
    attr_accessor :display_x, :display_y
    #--------------------------------------------------------------------------
    # * Set Display Position
    #--------------------------------------------------------------------------
    def set_display_pos(x, y)
        if ScrollingConfig.map_notscrollable.include?(@map_id) || $game_system.scroll_type == :not
            return nil
        end
        scroll_set_display_pos(x, y)
    end
end

#==============================================================================
# ** Game_System
#------------------------------------------------------------------------------
#  This class handles system data. It saves the disable state of saving and 
# menus. Instances of this class are referenced by $game_system.
#==============================================================================

class Game_System
    #--------------------------------------------------------------------------
    # * Alias
    #--------------------------------------------------------------------------
    alias scroll_initialize initialize
    #--------------------------------------------------------------------------
    # * Public Instance Variables
    #--------------------------------------------------------------------------
    attr_accessor :scroll_type, :scroll_speed
    #--------------------------------------------------------------------------
    # * Object Initialization
    #--------------------------------------------------------------------------
    def initialize
        scroll_initialize
        @scroll_type = ScrollingConfig::DEFAULT_TYPE
        @scroll_speed = ScrollingConfig::DEFAULT_SPEED
    end
end

#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  An interpreter for executing event commands. This class is used within the
# Game_Map, Game_Troop, and Game_Event classes.
#==============================================================================

class Game_Interpreter
    #--------------------------------------------------------------------------
    # * getAccess to param
    #--------------------------------------------------------------------------
    attr_accessor :params
    #--------------------------------------------------------------------------
    # * set ScrollType
    #--------------------------------------------------------------------------
    def scroll_type(type, speed=false)
        $game_system.scroll_type = type
        $game_system.scroll_speed = speed if speed
    end
    #--------------------------------------------------------------------------
    # * Switch index map
    #--------------------------------------------------------------------------
    def switch_display(x=0, y=0)
        $game_map.display_y, $game_map.display_x = y, x
    end
end

#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
#  This class handles the player. It includes event starting determinants and
# map scrolling functions. The instance of this class is referenced by
# $game_player.
#==============================================================================

class Game_Player
    #--------------------------------------------------------------------------
    # * Alias
    #--------------------------------------------------------------------------
    alias scroll_update_scroll update_scroll
    #--------------------------------------------------------------------------
    # * Scroll Processing
    #--------------------------------------------------------------------------
    def update_scroll(last_real_x, last_real_y)
        if ScrollingConfig.map_notscrollable.include?($game_map.map_id)
            return nil
        end
        case $game_system.scroll_type
        when :normal
            scroll_update_scroll(last_real_x, last_real_y)
        when :not
            not_scroll
        when :zelda
            zelda_scroll
        else
            scroll_update_scroll(last_real_x, last_real_y)
        end
    end
    #--------------------------------------------------------------------------
    # * Scrolling Zelda
    #--------------------------------------------------------------------------
    def zelda_scroll
        if self.screen_y > Graphics.height && $game_player.direction == 2
            $game_map.interpreter.params = [2,Graphics.height/32,$game_system.scroll_speed]
            $game_map.interpreter.command_204 while !$game_map.scrolling?
        end

        if self.screen_x <= 0 && $game_player.direction == 4
            $game_map.interpreter.params = [4,Graphics.width/32,$game_system.scroll_speed]
            $game_map.interpreter.command_204 while !$game_map.scrolling?
        end

        if self.screen_x > Graphics.width && $game_player.direction == 6
            $game_map.interpreter.params = [6,Graphics.width/32,$game_system.scroll_speed]
            $game_map.interpreter.command_204 while !$game_map.scrolling?
        end

        if self.screen_y <= 0 && $game_player.direction == 8
            $game_map.interpreter.params = [8,Graphics.height/32,$game_system.scroll_speed]
            $game_map.interpreter.command_204 while !$game_map.scrolling?
        end
    end
    #--------------------------------------------------------------------------
    # * no scrolling
    #--------------------------------------------------------------------------
    def not_scroll
        $game_map.display_y = $game_map.display_y
        $game_map.display_x = $game_map.display_x
    end
end