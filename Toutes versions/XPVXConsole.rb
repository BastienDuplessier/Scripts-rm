#==============================================================================
# ** Console Support for XP/VX
#------------------------------------------------------------------------------
# By Grim from http://www.biloucorp.com
#==============================================================================
# Function : 
#==============================================================================
# Console.log(text)  => display text in console
# console.log(text)  => display text in console
#==============================================================================
# ** Configuration
#------------------------------------------------------------------------------
# Configuration data
#==============================================================================

module Configuration
  #--------------------------------------------------------------------------
  # * Active Console (true=>activate console, false=>unactivate console)
  # * Only for XP and VX
  #--------------------------------------------------------------------------
  ENABLE_CONSOLE = true
end

#==============================================================================
# ** Console
#------------------------------------------------------------------------------
#  VXAce Console Handling
#==============================================================================

module Console
  #--------------------------------------------------------------------------
  # * Librairy
  #--------------------------------------------------------------------------
  AllocConsole        = Win32API.new('kernel32', 'AllocConsole', 'v', 'l')
  FindWindowA         = Win32API.new('user32', 'FindWindowA', 'pp', 'i')
  SetForegroundWindow = Win32API.new('user32', 'SetForegroundWindow','l','l')
  SetConsoleTitleA    = Win32API.new('kernel32','SetConsoleTitleA','p','s')
  WriteConsoleOutput  = Win32API.new('kernel32', 'WriteConsoleOutput', 'lpllp', 'l' )
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  extend self
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def init
    if (RUBY_VERSION != '1.9.2')
      return unless ($TEST || $DEBUG)
      hwnd = FindWindowA.call('RGSS Player', 0)
      AllocConsole.call
      SetForegroundWindow.call(hwnd)
      SetConsoleTitleA.call("RGSS Console")
      $stdout.reopen('CONOUT$')
    end
  end
  #--------------------------------------------------------------------------
  # * Log
  #--------------------------------------------------------------------------
  def log(*data)
    return unless ($TEST || $DEBUG)
    if (RUBY_VERSION == '1.9.2')
      p(*data)
      return
    end
    return unless Configuration::ENABLE_CONSOLE
    puts(*data.collect{|d|d.inspect})
  end
end

#==============================================================================
# ** Kernel
#------------------------------------------------------------------------------
#  Object class methods are defined in this module. 
#  This ensures compatibility with top-level method redefinition.
#==============================================================================

module Kernel
  #--------------------------------------------------------------------------
  # * Alias for console
  #--------------------------------------------------------------------------
  def console; Console; end
  #--------------------------------------------------------------------------
  # * pretty print
  #--------------------------------------------------------------------------
  if (RUBY_VERSION != '1.9.2') && ($TEST || $DEBUG)
    def p(*args)
      console.log(*args)
    end
  end
end

#--------------------------------------------------------------------------
# * Initialize Console
#--------------------------------------------------------------------------
Console.init if Configuration::ENABLE_CONSOLE