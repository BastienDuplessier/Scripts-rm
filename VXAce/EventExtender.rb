# Local variables and alternative commands version 1.1
# By Grim BILOUCORP - FUNKYWORK
# With components from Nuki (and based on one of his ideas)


# Special thanks to
# ------------------------------------------------------
# Nuki => Original Idea
# Zeus81 = > explanation about Pack, Polygons
# Hiino => Awesome translate ! Reformulation
# Joke => Math !

# Thanks to
# ------------------------------------------------------
# Molok, Zangther, Teraglehn,
# Lidenvice, Al Rind, Avygeil (inspiration, explanation about Pack),
# S4suk3, brandobscure (lol)
# ------------------------------------------------------
# http://www.biloucorp.com http://funkywork.blogspot.com (french)

# Credits
# ------------------------------------------------------
# Nothing :D

#==============================================================================
# ** Database module
#------------------------------------------------------------------------------
# This module allows the creation of your own database
# It can be used in 100% customized systems.
# Requires a good mastery of event making and some knowledge about Ruby
# Ref : documentation of the script
#==============================================================================

module Database
   #--------------------------------------------------------------------------
   # * Class variables
   #--------------------------------------------------------------------------
   @@tables = []
   #--------------------------------------------------------------------------
   # * Methods realted to Database
   #--------------------------------------------------------------------------
   class << self

      #--------------------------------------------------------------------------
      # * Database mapping
      #--------------------------------------------------------------------------
      def mapping
         #--------------------------------------------------------------------------
         # * Instructions
         # You can create the tables here
         #--------------------------------------------------------------------------
         # Creating a table : create_table("table name", field1: :type, field2: :type, etc)
         # List of available types = :integer, :float, :bool, :string
         create_table("Test", id: :int, name: :string, some_bool: :bool)

      end
      #--------------------------------------------------------------------------
      # * Filling the database with data
      #--------------------------------------------------------------------------
      def fill_tables
         # Filling the table "Test"
         # Filling a table: table("name") << [field1, field2 etc...]
         table("Test")  <<    [0, "A name", false]
      end
      #--------------------------------------------------------------------------
      # * Table creation
      #--------------------------------------------------------------------------
      def create_table(name, hash)
         @@tables << Table.new(name, hash)
      end
      #--------------------------------------------------------------------------
      # * Getting a table
      #--------------------------------------------------------------------------
      def table(name)
         @@tables.find do |tbl|
            tbl.name == name
         end
      end
      #--------------------------------------------------------------------------
      # * Finalizing the mapping
      #--------------------------------------------------------------------------
      def finalize
         mapping
         fill_tables
         @@tables
      end
   end

   #==============================================================================
   # ** Table
   #------------------------------------------------------------------------------
   # Describes a table from the database
   #==============================================================================

   class Table
      #--------------------------------------------------------------------------
      # * Instance variables
      #--------------------------------------------------------------------------
      attr_reader :name, :fields, :rows, :struct, :size, :types
      #--------------------------------------------------------------------------
      # * Constructor
      #--------------------------------------------------------------------------
      def initialize(name, hash)
         @name = name
         @fields = []
         @types = []
         hash.each do |key, type|
            @fields << key
            @types << type
         end
         @rows = []
         @struct = Struct.new(*(@fields.collect{|elt|elt.to_sym}))
         @size = 0
      end
      #--------------------------------------------------------------------------
      # * Converts to the adequate type
      #--------------------------------------------------------------------------
      def cast(value, type)
         type = type.to_sym
         result = value.to_s
         case type
         when :integer; result = value.to_i
         when :int; result = value.to_i
         when :float; result = value.to_f
         when :bool; result = !!value
         when :boolean; result = !!value
         end
         return result
      end
      #--------------------------------------------------------------------------
      # * Adds a column
      #--------------------------------------------------------------------------
      def add_row(*field)
         return if field.length != @fields.length
         (0...field.length).each do |elt|
            field[elt] = cast(field[elt], @types[elt])
         end
         @rows << @struct.new(*field)
         @size += 1
         end
      #--------------------------------------------------------------------------
      # * Alias of Add_row
      #--------------------------------------------------------------------------
      def << (fields)
         add_row(*fields)
      end
      #--------------------------------------------------------------------------
      # * Searches one piece of data
      #--------------------------------------------------------------------------
      def find(&block)
         @rows.find(&block)
      end
      #--------------------------------------------------------------------------
      # * Searches a bunch of data
      #--------------------------------------------------------------------------
      def select(&block)
         @rows.select(&block)
      end
      #--------------------------------------------------------------------------
      # * Counts the amount of data according to a predicate
      #--------------------------------------------------------------------------
      def count(&block)
         @rows.count(&block)
      end
   end
end

#==============================================================================
# ** Simple_Matrix
#------------------------------------------------------------------------------
# Handling matrixes easily
#==============================================================================

class Simple_Matrix
   #--------------------------------------------------------------------------
   # * Instance variables
   #--------------------------------------------------------------------------
   attr_accessor :table
   #--------------------------------------------------------------------------
   # * Constructor
   #--------------------------------------------------------------------------
   def initialize
      @table = []
   end
   #--------------------------------------------------------------------------
   # * Gets a value
   #--------------------------------------------------------------------------
   def [](*keys)
      table, f_key = @table, keys.pop
      keys.each do |key|
         table[key] ||= []
         table = table[key]
      end
      return table[f_key]
   end
   #--------------------------------------------------------------------------
   # * Sets a value
   #--------------------------------------------------------------------------
   def []=(*keys)
      value, f_key = keys.pop, keys.pop
      table = @table
      keys.each do |key|
         table[key] ||= []
         table = table[key]
      end
      table[f_key] = value
   end
end

#==============================================================================
# ** V
#------------------------------------------------------------------------------
# Variable handling API (by Nuki)
#==============================================================================

class V
   class << self
      #--------------------------------------------------------------------------
      # * Returns a Game Variable
      #--------------------------------------------------------------------------
      def [](id)
         return $game_variables[id]
      end
      #--------------------------------------------------------------------------
      # * Modifies a variable
      #--------------------------------------------------------------------------
      def []=(id, value)
         $game_variables[id] = value
      end
   end
end

#==============================================================================
# ** S
#------------------------------------------------------------------------------
# Switch handling API (by Nuki)
#==============================================================================

class S
   class << self
      #--------------------------------------------------------------------------
      # * Returns a Game Variable
      #--------------------------------------------------------------------------
      def [](id)
         return $game_switches[id]
      end
      #--------------------------------------------------------------------------
      # * Modifies a variable
      #--------------------------------------------------------------------------
      def []=(id, value)
         $game_switches[id] = value
      end
   end
end

#==============================================================================
# ** Numeric
#------------------------------------------------------------------------------
# Managing digits separately
#==============================================================================

class Numeric
   #--------------------------------------------------------------------------
   # * Number's units digit
   #--------------------------------------------------------------------------
   def units
      return self % 10
   end
   #--------------------------------------------------------------------------
   # * Number's tens digit
   #--------------------------------------------------------------------------
   def tens
      return ((self % 100)/10).to_i
   end
   #--------------------------------------------------------------------------
   # * Number's hundreds digit
   #--------------------------------------------------------------------------
   def hundreds
      return ((self % 1000)/100).to_i
   end
   #--------------------------------------------------------------------------
   # * Number's thousands digit
   #--------------------------------------------------------------------------
   def thousands
      return ((self % 10000)/1000).to_i
   end
   #--------------------------------------------------------------------------
   # * Number's tens of thousands digit
   #--------------------------------------------------------------------------
   def tens_thousands
      return ((self % 100000)/10000).to_i
   end
   #--------------------------------------------------------------------------
   # * Number's hundreds of thousands digit
   #--------------------------------------------------------------------------
   def hundreds_thousands
      return ((self % 1000000)/100000).to_i
   end
   #--------------------------------------------------------------------------
   # * Number's millions digit
   #--------------------------------------------------------------------------
   def millions
      return ((self % 10000000)/1000000).to_i
   end
   #--------------------------------------------------------------------------
   # * Number's tens of millions digit
   #--------------------------------------------------------------------------
   def tens_millions
      return ((self % 100000000)/10000000).to_i
   end
   #--------------------------------------------------------------------------
   # * Number's hundreds of millions digit
   #--------------------------------------------------------------------------
   def hundreds_millions
      return ((self % 1000000000)/100000000).to_i
   end
   #--------------------------------------------------------------------------
   # * alias
   #--------------------------------------------------------------------------
   alias unites units
   alias dizaines tens
   alias centaines hundreds
   alias milliers thousands
   alias dizaines_milliers tens_thousands
   alias centaines_milliers hundreds_thousands
   alias dizaines_millions tens_millions
   alias centaines_millions hundreds_millions
end


#==============================================================================
# ** Rect_Zone
#------------------------------------------------------------------------------
# Defining rectangular areas
#==============================================================================

class Rect_Zone
   #--------------------------------------------------------------------------
   # * Constructor
   #--------------------------------------------------------------------------
   def initialize(x1, y1, x2, y2)
      modify_coord(x1, y1, x2, y2)
   end
   #--------------------------------------------------------------------------
   # * Edits the coordinates
   #--------------------------------------------------------------------------
   def modify_coord(x1, x2, y1, y2)
      @x1, @x2 = x1,x2
      @x1, @x2 = @x2, @x1 if @x1 > @x2
      @y1, @y2 = y1, y2
      @y1, @y2 = @y2, @y1 if @y1 > @y2
      @raw_x1, @raw_y1, @raw_x2, @raw_y2 = @x1, @y1, @x2, @y2
   end
   #--------------------------------------------------------------------------
   # * Checks if a point (x, y) is in an area
   #--------------------------------------------------------------------------
   def in_area?(x, y)
      x >= @x1 && x <= @x2 && y >= @y1 && y <= @y2
   end
   #--------------------------------------------------------------------------
   # * Updates the area
   #--------------------------------------------------------------------------
   def update
      @x1 = @raw_x1 - ($game_map.display_x * 32)
      @y1 = @raw_y1 - ($game_map.display_y * 32)
      @x2 = @raw_x2 - ($game_map.display_x * 32)
      @y2 = @raw_y2 - ($game_map.display_y * 32)
   end
end

#==============================================================================
# ** Circle_Zone
#------------------------------------------------------------------------------
# Defining circular areas
#==============================================================================

class Circle_Zone
   #--------------------------------------------------------------------------
   # * Constructor
   #--------------------------------------------------------------------------
   def initialize(x, y, r)
      modify_coord(x, y, r)
   end
   #--------------------------------------------------------------------------
   # * Edits the coordinates
   #--------------------------------------------------------------------------
   def modify_coord(x, y, r)
      @x, @y, @r = x, y, r
      @raw_x, @raw_y = @x, @y
   end
   #--------------------------------------------------------------------------
   # * Updates the area
   #--------------------------------------------------------------------------
   def update
      @x = @raw_x - ($game_map.display_x * 32)
      @y = @raw_y - ($game_map.display_y * 32)
   end
   #--------------------------------------------------------------------------
   # * Checks if a point (x, y) is in an area
   #--------------------------------------------------------------------------
   def in_area?(x, y)
      ((x-@x)**2) + ((y-@y)**2) <= (@r**2)
   end
end


#==============================================================================
# ** Ellipse_Zone
#------------------------------------------------------------------------------
# Defining elliptic areas
#==============================================================================

class Ellipse_Zone
   #--------------------------------------------------------------------------
   # * Constructor
   #--------------------------------------------------------------------------
   def initialize(x, y, width, height)
      modify_coord(x, y, width, height)
   end
   #--------------------------------------------------------------------------
   # * Edits the coordinates
   #--------------------------------------------------------------------------
   def modify_coord(x, y, width, height)
      @x, @y, @width, @height = x, y, width, height
      @raw_x, @raw_y = @x, @y
   end
   #--------------------------------------------------------------------------
   # * Updates the area
   #--------------------------------------------------------------------------
   def update
      @x = @raw_x - ($game_map.display_x * 32)
      @y = @raw_y - ($game_map.display_y * 32)
   end
   #--------------------------------------------------------------------------
   # * Checks if a point (x, y) is in an area
   #--------------------------------------------------------------------------
   def in_area?(x, y)
      w = ((x.to_f-@x.to_f)**2.0)/(@width.to_f/2.0)
      h = ((y.to_f-@y.to_f)**2.0)/(@height.to_f/2.0)
      w + h <= 1
   end
end


#==============================================================================
# ** Polygon_Zone
#------------------------------------------------------------------------------
# Defining polygonal areas
#==============================================================================

class Polygon_Zone
   #--------------------------------------------------------------------------
   # * Constructor
   #--------------------------------------------------------------------------
   def initialize(points)
      modify_coord(points)
   end
   #--------------------------------------------------------------------------
   # * Edits the coordinates
   #--------------------------------------------------------------------------
   def modify_coord(points)
      @points = points
      @last_x = @last_y = 0
   end
   #--------------------------------------------------------------------------
   # * Updates the area
   #--------------------------------------------------------------------------
   def update
      new_x, new_y = $game_map.display_x * 32, $game_map.display_y * 32
      x_plus, y_plus = @last_x - new_x, @last_y - new_y
      @last_x, @last_y = new_x, new_y
      @points.each do |point|
         point[0] += x_plus
         point[1] += y_plus
      end
   end
   #--------------------------------------------------------------------------
   # * Finds the segment intersection function
   #--------------------------------------------------------------------------
   def intersectsegment(a_x, a_y, b_x, b_y, i_x, i_y, p_x, p_y)
      d_x, d_y = b_x - a_x, b_y - a_y
      e_x, e_y = p_x - i_x, p_y - i_y
      denominator = (d_x * e_y) - (d_y * e_x)
      return -1 if denominator == 0
      t = (i_x*e_y+e_x*a_y-a_x*e_y-e_x*i_y) / denominator
      return 0 if t < 0 || t >= 1
      u = (d_x*a_y-d_x*i_y-d_y*a_x+d_y*i_x) / denominator
      return 0 if u < 0 || u >= 1
      return 1
   end
   #--------------------------------------------------------------------------
   # * Checks if a point (x, y) is in an area
   #--------------------------------------------------------------------------
   def in_area?(p_x, p_y)
      i_x, i_y = 10000 + rand(100), 10000 + rand(100)
      nb_intersections = 0
      @points.each_index do |index|
         a_x, a_y = *@points[index]
         b_x, b_y = *@points[(index + 1) % @points.length]
         intersection = intersectsegment(a_x, a_y, b_x, b_y, i_x, i_y, p_x, p_y)
         return in_area?(p_x, p_y) if intersection == -1
         nb_intersections += intersection
      end
      return (nb_intersections%2 == 1)
   end
end


#==============================================================================
# ** HWND
#------------------------------------------------------------------------------
# Window managing library
#==============================================================================

module HWND
   #--------------------------------------------------------------------------
   # * Constants
   #--------------------------------------------------------------------------
   FindWindowA = Win32API.new('user32', 'FindWindowA', 'pp', 'l')
   GetPrivateProfileStringA = Win32API.new('kernel32', 'GetPrivateProfileStringA', 'pppplp', 'l')
   ShowCursor = Win32API.new('user32', 'ShowCursor', 'i', 'i')
   #--------------------------------------------------------------------------
   # * Binds methods to the class
   #--------------------------------------------------------------------------
   extend self
   #--------------------------------------------------------------------------
   # * Returns the RM HWND
   #--------------------------------------------------------------------------
   def get
      name = "\x00" * 256
      GetPrivateProfileStringA.('Game', 'Title', '', name, 255, ".\\Game.ini")
      name.delete!("\x00")
      return FindWindowA.('RGSS Player', name)
   end
   #--------------------------------------------------------------------------
   # * Defines cursor displaying
   #--------------------------------------------------------------------------
   def show_cursor(flag = true)
      value = flag ? 1 : 0
      ShowCursor.(value)
   end
end

#==============================================================================
# ** Mouse
#------------------------------------------------------------------------------
# Mouse features library
#==============================================================================

module Mouse
   #--------------------------------------------------------------------------
   # * Constants
   #--------------------------------------------------------------------------
   GetCursorPos = Win32API.new('user32', 'GetCursorPos', 'p', 'i')
   ScreenToClient = Win32API.new('user32', 'ScreenToClient', %w(l p), 'i')
   #--------------------------------------------------------------------------
   # * Binds methods to the class
   #--------------------------------------------------------------------------
   extend self
   #--------------------------------------------------------------------------
   # * Returns mouse position
   #--------------------------------------------------------------------------
   def position
      pos = [0, 0].pack('ll')
      p_value = nil
      p_value = pos.unpack('ll') unless GetCursorPos.(pos) == 0
      pos = [p_value[0], p_value[1]].pack('ll')
      p_value = nil
      p_value = pos.unpack('ll') if ScreenToClient.(HWND.get, pos)
      x, y = p_value
      return {x: x, y: y}
   end
end

#==============================================================================
# ** Key
#------------------------------------------------------------------------------
# List of available keys
#==============================================================================

module Key
   #--------------------------------------------------------------------------
   # * Constantes
   #--------------------------------------------------------------------------
   GetKeyState = Win32API.new('user32', 'GetKeyState', 'i', 'i')
   GetAsyncKeyState = Win32API.new('user32', 'GetAsyncKeyState', 'i', 'i')
   GetAsyncKeyState = Win32API.new('user32', 'GetAsyncKeyState', 'i', 'i')
   SetKeyboardState = Win32API.new("user32","SetKeyboardState",'p','i')
   GetKeyboardState = Win32API.new("user32","GetKeyboardState", 'p','i')

   class << self
      #--------------------------------------------------------------------------
      # * Checks if there is a click
      #--------------------------------------------------------------------------
      def click?(key)
         return GetKeyState.(key) > 1
      end
      #--------------------------------------------------------------------------
      # * Checks if a key is pressed
      #--------------------------------------------------------------------------
      def press?(key)
         return GetAsyncKeyState.(key) & 0x01 == 1
      end
   end
   #--------------------------------------------------------------------------
   # * List of keys
   #--------------------------------------------------------------------------
   # Control keys
   MOUSE_LEFT	= 0x01
   MOUSE_RIGHT	= 0x02
   BACKSPACE	= 0x08
   TAB = 0x09
   CLEAR	= 0x0C
   ENTER	= 0x0D
   SHIFT	= 0x10
   CTRL	= 0x11
   ALT = 0x12
   PAUSE	= 0x13
   CAPS_LOCK	= 0x14
   ESC = 0x1B
   SPACE	= 0x20
   PAGE_UP	= 0x22
   ENDKEY	= 0x23
   HOME	= 0x24
   LEFT = 0x25
   UP = 0x26
   RIGHT = 0x27
   DOWN	= 0x28
   SELECT	= 0x29
   PRINT	= 0x2A
   EXECUTE	= 0x2B
   HELP	= 0x2F
   # Numeric keys
   ZERO	= 0x30
   ONE = 0x31
   TWO	= 0x32
   THREE	= 0x33
   FOUR	= 0x34
   FIVE	= 0x35
   SIX = 0x36
   SEVEN = 0x37
   EIGHT	= 0x38
   NINE = 0x39
   # Letter keys
   A = 0x41
   B = 0x42
   C = 0x43
   D = 0x44
   E = 0x45
   F = 0x46
   G = 0x47
   H = 0x48
   I = 0x49
   J = 0x4A
   K = 0x4B
   L = 0x4C
   M = 0x4D
   N = 0x4E
   O = 0x4F
   P = 0x50
   Q	= 0x51
   R = 0x52
   S = 0x53
   T = 0x54
   U = 0x55
   V = 0x56
   W = 0x57
   X = 0x58
   Y = 0x59
   Z = 0x5A
   # Windows-related keys
   LWINDOW	= 0x5B	
   RWINDOW	= 0x5C
   APPS	= 0x5D
   # Numeripad
   NUM_ZERO	= 0x60
   NUM_ONE	= 0x61
   NUM_TWO	= 0x62
   NUM_THREE	= 0x63
   NUM_FOR	= 0x64
   NUM_FIVE	= 0x65
   NUM_SIX	= 0x66
   NUM_SEVEN	= 0x67
   NUM_EIGHT	= 0x68
   NUM_NINE	= 0x69
   MULTIPLY	= 0x6A
   ADD	= 0x6B
   SEPARATOR	= 0x6C
   SUBSTRACT	= 0x6D
   DECIMAL	= 0x6E
   DIVIDE	= 0x6F
   # F keys
   F1	= 0x70
   F2	= 0x71
   F3	= 0x72
   F4	= 0x73
   F5	= 0x74
   F6	= 0x75
   F7	= 0x76
   F8	= 0x77
   F9	= 0x78
   F10	= 0x79
   F11	= 0x7A
   F12	= 0x7B
   # More control keys
   NUM_LOCK	= 0x90
   SCROLL	= 0x91
   LSHIFT	= 0xA0
   RSHIFT	= 0xA1
   LCONTROL	= 0xA2
   RCONTROL	= 0xA3
   LMENU	= 0xA4
   RMENU	= 0xA5
end

#==============================================================================
# ** Socket
#------------------------------------------------------------------------------
# Adds the possibility to send/receive messages to/from a server
# Big thanks to Zeus81 (and to Nuki, too)
#==============================================================================

module Socket
   #--------------------------------------------------------------------------
   # * Win32API
   #--------------------------------------------------------------------------
   Socket = Win32API.new('ws2_32', 'socket', 'lll', 'l')
   Connect = Win32API.new('ws2_32', 'connect', 'ppl', 'l')
   Close = Win32API.new('ws2_32', 'closesocket', 'p', 'l')
   Send = Win32API.new('ws2_32', 'send', 'ppll', 'l')
   Recv = Win32API.new('ws2_32', 'recv', 'ppll', 'l')
   Inet_addr = Win32API.new('ws2_32', 'inet_addr', 'p', 'l')
   Htons = Win32API.new('ws2_32', 'htons', 'l', 'l')
   Shutdown = Win32API.new('ws2_32', 'shutdown', 'pl', 'l')
   #--------------------------------------------------------------------------
   # * Constants
   #--------------------------------------------------------------------------
   AF_INET = 2
   SOCK_STREAM = 1
   #--------------------------------------------------------------------------
   # * Singleton
   #--------------------------------------------------------------------------
   class << self
      #--------------------------------------------------------------------------
      # * Creating the SOCKADDR_IN
      #--------------------------------------------------------------------------
      def sockaddr_in(host, port)
         sin_family = AF_INET
         sin_port = Htons.(port)
         in_addr = Inet_addr.(host)
         sockaddr_in = [sin_family, sin_port, in_addr].pack('sSLx8')
         return sockaddr_in
      end
      #--------------------------------------------------------------------------
      # * Creating the Socket
      #--------------------------------------------------------------------------
      def socket() return Socket.(AF_INET, SOCK_STREAM, 0) end
      #--------------------------------------------------------------------------
      # * Connecting
      #--------------------------------------------------------------------------
      def connect_sock(sock, sockaddr)
         if Connect.(sock, sockaddr, sockaddr.size) == -1
         p "Impossible to connect"
         return
         end
         p "Successfully connected"
      end
      #--------------------------------------------------------------------------
      # * Connecting
      #--------------------------------------------------------------------------
      def connect(host = "127.0.0.1", port = 9999)
         sockaddr = sockaddr_in(host, port)
         sock = socket()
         connect_sock(sock, sockaddr)
         return sock
      end
      #--------------------------------------------------------------------------
      # * Sending data
      #--------------------------------------------------------------------------
      def send(socket, data)
         value = Send.(socket, data, data.length, 0)
         if value == -1
            p "Failed to send"
            shutdown(socket, 2)
            return false
         end
         p "Successfully sent"
         return true
      end
      #--------------------------------------------------------------------------
      # * Receiving data
      #--------------------------------------------------------------------------
      def recv(socket, len = 256)
         buffer = [].pack('x'+len.to_s)
         value = Recv.(socket, buffer, len, 0)
         return buffer.gsub(/\x00/, "") if value != -1
         return false
      end
      #--------------------------------------------------------------------------
      # * Stops the emission
      #--------------------------------------------------------------------------
      def shutdown(socket, how) Shutdown.(socket, how) end
      #--------------------------------------------------------------------------
      # * Closes the connection
      #--------------------------------------------------------------------------
      def close(socket) Close.(socket) end
   end
end

#==============================================================================
# ** Game_Picture
#------------------------------------------------------------------------------
# Modifies reading rights
#==============================================================================

class Game_Picture
   #--------------------------------------------------------------------------
   # * Public instance variables
   #--------------------------------------------------------------------------
   attr_accessor :opacity, :zoom_x, :zoom_y, :x, :y, :blend_type, :tone, :origin, :angle
end

#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
# Pins a picture to the map
#==============================================================================

class Game_Map
   #--------------------------------------------------------------------------
   # * Alias
   #--------------------------------------------------------------------------
   alias pin_setup setup
   alias pin_initialize initialize
   #--------------------------------------------------------------------------
   # * Instance variables
   #--------------------------------------------------------------------------
   attr_accessor :pinned_pictures
   attr_accessor :kept_pictures
   #--------------------------------------------------------------------------
   # * Constructor
   #--------------------------------------------------------------------------
   def initialize
      pin_initialize
      @kept_pictures = []
   end
   #--------------------------------------------------------------------------
   # * Setup
   #--------------------------------------------------------------------------
   def setup(map_id)
      pin_setup(map_id)
      (1..20).each do |id|
         if @screen.pictures[id]
            @screen.pictures[id].erase unless kept?(id)
         end
      end
      @pinned_pictures = []
   end
   #--------------------------------------------------------------------------
   # * Defines pinned pictures
   #--------------------------------------------------------------------------
   def set_pinned_pictures(ids)
      @pinned_pictures = ids
   end
   #--------------------------------------------------------------------------
   # * Forces a picture to stay on the screen after teleporting
   #--------------------------------------------------------------------------
   def keep_pictures(ids)
      @kept_pictures += ids
      @kept_pictures.uniq!
   end
   #--------------------------------------------------------------------------
   # * Allows a picture to disappear when teleporting
   #--------------------------------------------------------------------------
   def release_pictures(ids)
      ids.each do |id|
         @kept_pictures.delete(id)
      end
   end
   #--------------------------------------------------------------------------
   # * Checks if a picture is pinned
   #--------------------------------------------------------------------------
   def pinned?(id)
      @pinned_pictures.include?(id)
   end
   #--------------------------------------------------------------------------
   # * Checks if a picture is kept on the screen after teleporting
   #--------------------------------------------------------------------------
   def kept?(id)
      @kept_pictures.include?(id)
   end
end

#==============================================================================
# ** Sprite_Picture
#------------------------------------------------------------------------------
# This sprite is used to display pictures. It observes an instance of the
# Game_Picture class and automatically changes sprite states.
#==============================================================================

class Sprite_Picture
   #--------------------------------------------------------------------------
   # * alias
   #--------------------------------------------------------------------------
   alias pin_initialize initialize
   alias pin_update_position update_position
   #--------------------------------------------------------------------------
   # * Public instance variables
   #--------------------------------------------------------------------------
   attr_accessor :anchor
   #--------------------------------------------------------------------------
   # * Object initialization
   # picture : Game_Picture
   #--------------------------------------------------------------------------
   def initialize(viewport, picture)
      pin_initialize(viewport, picture)
      @anchor = (@picture.name =~ /^FIX\-/) != nil
   end
   #--------------------------------------------------------------------------
   # * Update Position
   #--------------------------------------------------------------------------
   def update_position
      @anchor = (@picture.name =~ /^FIX\-/) != nil || $game_map.pinned?(@picture.number)
      if @anchor
         new_x = @picture.x - ($game_map.display_x * 32)
         new_y = @picture.y - ($game_map.display_y * 32)
         self.x, self.y = new_x, new_y
      else
         self.x = @picture.x
         self.y = @picture.y
         self.z = @picture.number
      end
   end
end

#==============================================================================
# ** Picture
#------------------------------------------------------------------------------
# Handling pictures
#==============================================================================

module Picture
   extend self
   #--------------------------------------------------------------------------
   # * Returns the game screen
   #--------------------------------------------------------------------------
   def get_screen
      $game_map.respond_to?(:screen) ? $game_map.screen : $game_screen
   end
   #--------------------------------------------------------------------------
   # * Changes the opacity
   #--------------------------------------------------------------------------
   def change_opacity(id, value)
      value %=256
      get_screen.pictures[id].opacity = value
   end
   #--------------------------------------------------------------------------
   # * Changes the zoom
   #--------------------------------------------------------------------------
   def change_zoom(id, val_x, val_y)
      val_x = val_x.abs
      val_y = val_y.abs
      get_screen.pictures[id].zoom_x = val_x
      get_screen.pictures[id].zoom_y = val_y
   end
   #--------------------------------------------------------------------------
   # * Changes the tone
   #--------------------------------------------------------------------------
   def change_tone(id, r, v, b, g=0)
      r, v, b, g = r%256, v%256, b%256, g%256
      get_screen.pictures[id].tone = Tone.new(r,v,b,g)
   end
   #--------------------------------------------------------------------------
   # * Changes the angle
   #--------------------------------------------------------------------------
   def change_angle(id, angle)
      get_screen.pictures[id].angle = angle%360
   end
end

#==============================================================================
# ** Line
#------------------------------------------------------------------------------
# Creates an imaginary line
#==============================================================================

class Line
   #--------------------------------------------------------------------------
   # * Public Instance Variables
   #--------------------------------------------------------------------------
   attr_accessor :sx, :sy, :cx, :cy
   #--------------------------------------------------------------------------
   # * Constructor
   #--------------------------------------------------------------------------
   def initialize(x1,y1,x2,y2)
      @sx, @sy, @cx, @cy = x1, y1, x2, y2
      if @sx != @cx
         @a = (@sy-@cy)/(@sx-@cx).to_f
         @b = (@sy - @sx*@a).to_f
      end
   end
   #--------------------------------------------------------------------------
   # * Returns the equation of the line
   #--------------------------------------------------------------------------
   def equation
      return nil if @sx == @cx
      fun = lambda{|ap, bp, x|ap*x + bp}
      return fun.curry.(@a, @b)
   end
   #--------------------------------------------------------------------------
   # * Returns the Y for a given X
   #--------------------------------------------------------------------------
   def [](x)
      return nil if @cx == @sx
      return (@a * x + @b)
   end
   #--------------------------------------------------------------------------
   # * Checks the position of a point in relation to a line
   #--------------------------------------------------------------------------
   def position(x, y)
      if @sx == @cx
         return -1 if x < @cx
         return 1 if x > @cx
         return 0
      end
      return -1 if y > @a*x+@b
      return 1 if y < @a*x+@b
      return 0
   end
end

#==============================================================================
# ** Command
#------------------------------------------------------------------------------
# Adds easily usable commands
#==============================================================================

module Command
   #--------------------------------------------------------------------------
   # * Command singleton
   #--------------------------------------------------------------------------
   extend self
   #--------------------------------------------------------------------------
   # * Standard operands
   #--------------------------------------------------------------------------
   def random(x, y) (x + rand(y - x)) end
   def map_id() $game_map.map_id end
   def var(id) $game_variables[id] end
   def set_var(id, value)
      $game_variables[id] = value
   end
   def percent(value, max) (value*100)/max end
   def proportion(percent, max) (percent*max)/100 end
   #--------------------------------------------------------------------------
   # * Tools for line management
   #--------------------------------------------------------------------------
   def line(sx, sy, cx, cy) Line.new(sx, sy, cx, cy) end
   #--------------------------------------------------------------------------
   # * Operands for the party
   #--------------------------------------------------------------------------
   def team_size() $game_party.members.size end
   def gold() $game_party.gold end
   def steps() $game_party.steps end
   def play_time() (Graphics.frame_count / Graphics.frame_rate) end
   def timer() $game_timer.sec end
   def save_count() $game_system.save_count end
   def battle_count() $game_system.battle_count end
   #--------------------------------------------------------------------------
   # * Oerands for the items
   #--------------------------------------------------------------------------
   def item_count(id) $game_party.item_number($data_items[id]) end
   def weapon_count(id) $game_party.item_number($data_weapons[id]) end
   def armor_count(id) $game_party.item_number($data_armors[id]) end
   #--------------------------------------------------------------------------
   # * Operands for the actors
   #--------------------------------------------------------------------------
   def actor(id) $game_actors[id] end
   def level(id) $game_actors[id].level end
   def experience(id) $game_actors[id].exp end
   def hp(id) $game_actors[id].hp end
   def mp(id) $game_actors[id].mp end
   def max_hp(id) $game_actors[id].mhp end
   def max_mp(id) $game_actors[id].mmp end
   def attack(id) $game_actors[id].atk end
   def defense(id) $game_actors[id].def end
   def magic(id) $game_actors[id].mat end
   def magic_defense(id) $game_actors[id].mdf end
   def agility(id) $game_actors[id].agi end
   def luck(id) $game_actors[id].luk end
   #--------------------------------------------------------------------------
   # * Operands for the events
   #--------------------------------------------------------------------------
   def event_x(id)
      character = $game_player
      character = $game_map.events[id] unless id == 0
      character.x
   end
   def event_y(id)
      character = $game_player
      character = $game_map.events[id] unless id == 0
      character.y
   end
   def event_direction(id)
      character = $game_player
      character = $game_map.events[id] unless id == 0
      character.direction
   end
   def event_screen_x(id)
      character = $game_player
      character = $game_map.events[id] unless id == 0
      character.screen_x
   end
   def event_screen_y(id)
      character = $game_player
      character = $game_map.events[id] unless id == 0
      character.screen_y
   end
   def heroes_x() Command.event_x(0) end
   def heroes_y() Command.event_y(0) end
   def heroes_direction() Command.event_direction(0) end
   def heroes_screen_x() Command.event_screen_x(0) end
   def heroes_screen_y() Command.event_screen_y(0) end
   def distance_between_squares(ev1, ev2)
      event1 = (ev1 == 0) ? $game_player : $game_map.events[ev1]
      event2 = (ev2 == 0) ? $game_player : $game_map.events[ev2]
      Math.hypot((event1.x - event2.x), (event1.y-event2.y))
   end
   def distance_between_pixels(ev1, ev2)
      event1 = (ev1 == 0) ? $game_player : $game_map.events[ev1]
      event2 = (ev2 == 0) ? $game_player : $game_map.events[ev2]
      Math.hypot((event1.screen_x - event2.screen_x), (event1.screen_y-event2.screen_y))
   end
   #--------------------------------------------------------------------------
   # * More operands for the party
   #--------------------------------------------------------------------------
   def actor_id(position)
      $game_party.members[position]
      return actor ? actor.id : 0
   end
   #--------------------------------------------------------------------------
   # * Commands for database reading
   #--------------------------------------------------------------------------
   def read_monster_data(id, method = false)
      monster = $data_enemies[id]
      return monster unless method
      method = method.to_sym
      value = false
      value = 0 if method == :mhp || method == :hp
      value = 1 if method == :mmp || method == :mp
      value = 2 if method == :atk || method == :attack
      value = 3 if method == :def || method == :defense
      value = 4 if method == :mat || method == :magic_attack
      value = 5 if method == :mdf || method == :magic_defense
      value = 6 if method == :agi || method == :agility
      value = 7 if method == :luk || method == :luck
      return monster.params[value] if value
      monster.send(method)
   end
   def read_data_skill(id, method = false)
      skill = $data_skills[id]
      return skill unless method
      skill.send(method.to_sym)
   end
   #--------------------------------------------------------------------------
   # * Area handling
   #--------------------------------------------------------------------------
   def create_area(*args)
      symbol = args[0]
      if symbol == :rectangle || symbol == :rect
         x1, y1, x2, y2 = args[1], args[2], args[3], args[4]
         return Rect_Zone.new(x1, x2, y1, y2)
      elsif symbol == :circle
         x, y, r = args[1], args[2], args[3]
         return Circle_Zone.new(x, y, r)

      elsif symbol == :Ellipse
         x1, y1, w, h = args[1], args[2], args[3], args[4]
         return Ellipse_Zone.new(x1, y1, w, h)
      else
         return Polygon_Zone.new(args[1])
      end
   end
   #--------------------------------------------------------------------------
   # * Picture handling
   #--------------------------------------------------------------------------
   def picture_opacity(id, value) Picture.change_opacity(id, value) end
   def picture_angle(id, value) Picture.change_angle(id, value) end
   def picture_zoom(id, value_x, value_y) Picture.change_zoom(id, value_x, value_y) end
   def picture_tone(id, r, v, b, g=0) Picture.change_tone(id, r, v, b, g) end
   def pin_pictures(*ids) $game_map.set_pinned_pictures(ids) end
   def keep_pictures(*ids) $game_map.keep_pictures(ids) end
   def release_pictures(*ids) $game_map.release_pictures(ids) end
   #--------------------------------------------------------------------------
   # * Save handling
   #--------------------------------------------------------------------------
   def save_game(index) DataManager.save_game(index-1) end
   def load_game(index, time = 100) 
      DataManager.load_game(index-1) 
      RPG::BGM.fade(time)
      RPG::BGS.fade(time)
      RPG::ME.fade(time)
      Graphics.fadeout(time * Graphics.frame_rate / 1000)
      RPG::BGM.stop
      RPG::BGS.stop
      RPG::ME.stop
      $game_system.on_after_load
      SceneManager.goto(Scene_Map)
   end
   def save_exists?(index) DataManager.save_file_exists? end
   def delete_save(index) DataManager.delete_save_file(index-1) end
   #--------------------------------------------------------------------------
   # * Device handling
   #--------------------------------------------------------------------------
   def get_mouse_x() Mouse.position[:x] end
   def get_mouse_y() Mouse.position[:y] end
   def mouse_click?(key) Key.click?(key) end
   def key_press?(key) Key.press?(key) end
   def hide_cursor() HWND.show_cursor(false) end
   #--------------------------------------------------------------------------
   # * Alternative database handling
   #--------------------------------------------------------------------------
   def table(name)
      $game_database.find do |elt|
         elt.name == name
      end
   end
   #--------------------------------------------------------------------------
   # * Socket handling
   #--------------------------------------------------------------------------
   def connect(host, port) Socket.connect(host, port) end
   def send_to_server(socket, value) Socket.send(socket, value) end
   def recv_from_server(socket, len = 256) Socket.recv(socket, len) end
   def wait_for_recv(socket, len = 256)
      flag = false
      flag = Socket.recv(socket, len) while !flag
      return flag
   end
end

#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
# Adding of the local variables support
#==============================================================================

class Game_Interpreter
   #--------------------------------------------------------------------------
   # * Getting a local variable
   #--------------------------------------------------------------------------
   def get(*arguments)
      result = 0
      case arguments.length
      when 1; result = $game_selfVars[@map_id, @event_id, arguments[0]]
      when 2; result = $game_selfVars[@map_id, arguments[0], arguments[1]]
      when 3; result = $game_selfVars[arguments[0], arguments[1], arguments[2]]
      end
      return result
   end
   #--------------------------------------------------------------------------
   # * Setting a local variable
   #--------------------------------------------------------------------------
   def set(*arguments)
      case arguments.length
      when 2; $game_selfVars[@map_id, @event_id, arguments[0]] = arguments[1]
      when 3; $game_selfVars[@map_id, arguments[0], arguments[1]] = arguments[2]
      when 4; $game_selfVars[arguments[0], arguments[1], arguments[2]] = arguments[3]
      end
   end
   alias let set
   #--------------------------------------------------------------------------
   # * API for command handling
   #--------------------------------------------------------------------------
   def cmd(command, *arguments) Command.send(command.to_sym, *arguments) end
   #--------------------------------------------------------------------------
   # * Alias
   #--------------------------------------------------------------------------
   alias command cmd
   alias c cmd
   #--------------------------------------------------------------------------
   # * API for variable handling
   #--------------------------------------------------------------------------
   def variable(id, value) $game_variables[id] = value end
   #--------------------------------------------------------------------------
   # * API for monsters/actors/techniques/tables
   #--------------------------------------------------------------------------
   def enemy(id) cmd(:read_data_monster, id) end
   def actor(id) cmd(:actor, id) end
   def skill(id) cmd(:read_data_skill, id) end
   def table(name)cmd(:table, name) end
end

#==============================================================================
# ** DataManager
#------------------------------------------------------------------------------
# Lcal variables
#==============================================================================

module DataManager
   class << self
      #--------------------------------------------------------------------------
      # * Alias
      #--------------------------------------------------------------------------
      alias local_create_game_objects create_game_objects
      alias local_make_save_contents make_save_contents
      alias local_extract_save_contents extract_save_contents
      #--------------------------------------------------------------------------
      # * Creates the objects of the game
      #--------------------------------------------------------------------------
      def create_game_objects
         local_create_game_objects
         $game_selfVars = Simple_Matrix.new
         $game_database = Database.finalize
      end
      #--------------------------------------------------------------------------
      # * Saves the contents of the game
      #--------------------------------------------------------------------------
      def make_save_contents
         contents = local_make_save_contents
         contents[:self_vars] = $game_selfVars
         contents
      end
      #--------------------------------------------------------------------------
      # * Charges a save
      #--------------------------------------------------------------------------
      def extract_save_contents(contents)
         local_extract_save_contents(contents)
         $game_selfVars = contents[:self_vars]
         $game_database = Database.finalize
      end
   end
end

#==============================================================================
# ** Kernel
#------------------------------------------------------------------------------
# Adds the "cmd" function in order to be used in scripts
#==============================================================================

module Kernel
   #--------------------------------------------------------------------------
   # * API for table handling
   #--------------------------------------------------------------------------
   def table(name) Command.table("name") end
   #--------------------------------------------------------------------------
   # * API for command handling
   #--------------------------------------------------------------------------
   def cmd(command, *arguments) Command.send(command.to_sym, *arguments) end
   #--------------------------------------------------------------------------
   # * Alias
   #--------------------------------------------------------------------------
   alias command cmd
   alias c cmd
end