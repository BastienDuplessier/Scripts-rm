#==============================================================================
# ** Sound
#------------------------------------------------------------------------------
#  This module plays sound effects. It obtains sound effects specified in the
# database from $data_system, and plays them.
#==============================================================================

module Sound
  extend self
  # Curseur
  def play_dialog
    $data_system.sounds[0].play
  end
end

#==============================================================================
# ** Game_Message
#------------------------------------------------------------------------------
#  This class handles the state of the message window that display text or
# selections, etc. The instance of this class is referenced by $game_message.
#==============================================================================

class Window_Message
  alias sound_wait_for_one_character wait_for_one_character
  def wait_for_one_character
    sound_wait_for_one_character
    Sound.play_dialog unless @show_fast || @line_show_fast
  end
end