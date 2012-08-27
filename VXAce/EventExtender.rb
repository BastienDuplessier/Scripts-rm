# Variables locales et commandes alternatives version 1.1
# Par Grim BILOUCORP - FUNKYWORK
# Avec des composantes de Nuki (et sur base d'une de ses idées)

# Remerciements
# ------------------------------------------------------
# Nuki, Molok, Zangther, Joke (maaath), Magicalichigo, Teraglehn, Hiino (pour des vérifs, traduction)
# Lidenvice, Al Rind, Avygeil (pour l'inspiration et pour son explication sur pack), 
# S4suk3, brandobscure (lol), Zeus81 (Pack, GetKeyState, Union etc ...)
# ------------------------------------------------------
# http://www.biloucorp.com http://funkywork.blogspot.com

# Crédit
# ------------------------------------------------------
# :D rien 

#==============================================================================
# ** Module database
#------------------------------------------------------------------------------
#  Ce module permet la création d'une base de données personnalisée
#  Elle peut s'utiliser dans des systèmes 100% originaux.
#  Requiert un bon niveau en Event making et quelques notions en Ruby 
#  Ref : Documentation du script
#==============================================================================

module Database
	#--------------------------------------------------------------------------
	# * Variables de classes
	#--------------------------------------------------------------------------
	@@tables = []
	#--------------------------------------------------------------------------
	# * Méthodes propre à Database
	#--------------------------------------------------------------------------
	class << self

		#--------------------------------------------------------------------------
		# * Mapping de la base de données
		#--------------------------------------------------------------------------
		def mapping
			#--------------------------------------------------------------------------
			# * Instructions
			# C'est dans cette partie que vous allez pouvoir créer toutes les tables
			#--------------------------------------------------------------------------
			# Créer une table : create_table("nom de la table", champ1: :type, champ2: :type, etc)
			# Liste des types disponnibles = :integer, :float, :bool, :string
			create_table("Essai", id: :int, name: :string, some_bool: :bool)

		end
		#--------------------------------------------------------------------------
		# * Remplis la base de données de données :D
		#--------------------------------------------------------------------------
		def fill_tables
			# Remplissage de la table Essai
			# Remplir une table : table("nom") << [champ1, champ2 etc...]
			table("Essai")  << 	[0, "Uun nom", false]
		end
		#--------------------------------------------------------------------------
		# * Crée une table
		#--------------------------------------------------------------------------
		def create_table(name, hash)
			@@tables << Table.new(name, hash)
		end
		#--------------------------------------------------------------------------
		# * Récupère une table
		#--------------------------------------------------------------------------
		def table(name)
			@@tables.find do |tbl|
				tbl.name == name
			end
		end
		#--------------------------------------------------------------------------
		# * Finalise le mapping
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
	#  Décri une table de la base de données
	#==============================================================================

	class Table
		#--------------------------------------------------------------------------
		# * Variables d'instances
		#--------------------------------------------------------------------------
		attr_reader :name, :fields, :rows, :struct, :size, :types
		#--------------------------------------------------------------------------
		# * Constructeur 
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
		# * convertit dans le type adéquat
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
		# * Ajoute une colonne
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
		# * Alias de Add_row
		#--------------------------------------------------------------------------
		def << (fields)
			add_row(*fields)
		end
		#--------------------------------------------------------------------------
		# * Cherche une donnée
		#--------------------------------------------------------------------------
		def find(&block)
			@rows.find(&block)
		end
		#--------------------------------------------------------------------------
		# * Cherche une collection de données
		#--------------------------------------------------------------------------
		def select(&block)
			@rows.select(&block)
		end
		#--------------------------------------------------------------------------
		# * Compte le nombre de données en fonction d'un prédicat
		#--------------------------------------------------------------------------
		def count(&block)
			@rows.count(&block)
		end
	end
end

#==============================================================================
# ** Simple_Matrix
#------------------------------------------------------------------------------
#  Manipulation de matrice facilement
#==============================================================================

class Simple_Matrix
	#--------------------------------------------------------------------------
	# * Variables d'instances
	#--------------------------------------------------------------------------
	attr_accessor :table
	#--------------------------------------------------------------------------
	# * Construction
	#--------------------------------------------------------------------------
	def initialize
		@table = []
	end
	#--------------------------------------------------------------------------
	# * Récupère une valeur
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
	# * Attribue une valeur
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
#  API de manipulation de variable (Par Nuki)
#==============================================================================

class V
	class << self
		#--------------------------------------------------------------------------
		# * Return a Game Variable
		#--------------------------------------------------------------------------
		def [](id)
			return $game_variables[id]
		end
		#--------------------------------------------------------------------------
		# * Modify a variable
		#--------------------------------------------------------------------------
		def []=(id, value)
			$game_variables[id] = value
		end
	end
end

#==============================================================================
# ** S
#------------------------------------------------------------------------------
#  API de manipulation des interrupteurs (Par Nuki)
#==============================================================================

class S
	class << self
		#--------------------------------------------------------------------------
		# * Return a Game Variable
		#--------------------------------------------------------------------------
		def [](id)
			return $game_switches[id]
		end
		#--------------------------------------------------------------------------
		# * Modify a variable
		#--------------------------------------------------------------------------
		def []=(id, value)
			$game_switches[id] = value
		end
	end
end

#==============================================================================
# ** Numeric
#------------------------------------------------------------------------------
#  Ajout de la gestion de chaque chiffre d'un nombre
#==============================================================================

class Numeric
	#--------------------------------------------------------------------------
	# * Unitées du nombre
	#--------------------------------------------------------------------------
	def unites
		return self % 10
	end
	#--------------------------------------------------------------------------
	# * dizaines du nombre
	#--------------------------------------------------------------------------
	def dizaines
		return ((self % 100)/10).to_i
	end
	#--------------------------------------------------------------------------
	# * centaines du nombre
	#--------------------------------------------------------------------------
	def centaines
		return ((self % 1000)/100).to_i
	end
	#--------------------------------------------------------------------------
	# * milliers du nombre
	#--------------------------------------------------------------------------
	def milliers
		return ((self % 10000)/1000).to_i
	end
	#--------------------------------------------------------------------------
	# * dizaines milliers du nombre
	#--------------------------------------------------------------------------
	def dizaines_milliers
		return ((self % 100000)/10000).to_i
	end
	#--------------------------------------------------------------------------
	# * centaines milliers du nombre
	#--------------------------------------------------------------------------
	def centaines_milliers
		return ((self % 1000000)/100000).to_i
	end
	#--------------------------------------------------------------------------
	# * milions
	#--------------------------------------------------------------------------
	def millions
		return ((self % 10000000)/1000000).to_i
	end
	#--------------------------------------------------------------------------
	# * dizaines de milions
	#--------------------------------------------------------------------------
	def dizaines_millions
		return ((self % 100000000)/10000000).to_i
	end
	#--------------------------------------------------------------------------
	# * centaines de milions
	#--------------------------------------------------------------------------
	def centaines_millions
		return ((self % 1000000000)/100000000).to_i
	end
end


#==============================================================================
# ** Rect_Zone
#------------------------------------------------------------------------------
#  Définition de zone rectangulaire
#==============================================================================

class Rect_Zone
	#--------------------------------------------------------------------------
  	# * Constructeur
  	#--------------------------------------------------------------------------
  	def initialize(x1, y1, x2, y2)
  		modify_coord(x1, y1, x2, y2)
  	end
  	#--------------------------------------------------------------------------
  	# * modifie les coordonnées
  	#--------------------------------------------------------------------------
  	def modify_coord(x1, x2, y1, y2)
  		@x1, @x2 = x1,x2
  		@x1, @x2 = @x2, @x1 if @x1 > @x2
  		@y1, @y2 = y1, y2
  		@y1, @y2 = @y2, @y1 if @y1 > @y2
  		@raw_x1, @raw_y1, @raw_x2, @raw_y2 = @x1, @y1, @x2, @y2
  	end
  	#--------------------------------------------------------------------------
  	# * vérifie si des coordonnées sont dans une zone
  	#--------------------------------------------------------------------------
  	def in_zone?(x, y)
  		x >= @x1 && x <= @x2 && y >= @y1 && y <= @y2
  	end
  	#--------------------------------------------------------------------------
  	# * Met a jours la zone
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
#  Définition de zone circulaire
#==============================================================================

class Circle_Zone
	#--------------------------------------------------------------------------
  	# * Constructeur
  	#--------------------------------------------------------------------------
  	def initialize(x, y, r)
  		modify_coord(x, y, r)
  	end
  	#--------------------------------------------------------------------------
  	# * modifie les coordonnées
  	#--------------------------------------------------------------------------
  	def modify_coord(x, y, r)
  		@x, @y, @r = x, y, r 
  		@raw_x, @raw_y = @x, @y
  	end
  	#--------------------------------------------------------------------------
  	# * Met a jours la zone
  	#--------------------------------------------------------------------------
  	def update
  		@x = @raw_x - ($game_map.display_x * 32)
  		@y = @raw_y - ($game_map.display_y * 32)
  	end
  	#--------------------------------------------------------------------------
  	# * vérifie si des coordonnées sont dans une zone
  	#--------------------------------------------------------------------------
  	def in_zone?(x, y)
  		((x-@x)**2) + ((y-@y)**2) <= (@r**2)
  	end
end


#==============================================================================
# ** Ellipse_Zone
#------------------------------------------------------------------------------
#  Définition de zone elliptique
#==============================================================================

class Ellipse_Zone
	#--------------------------------------------------------------------------
  	# * Constructeur
  	#--------------------------------------------------------------------------
  	def initialize(x, y, width, height)
  		modify_coord(x, y, width, height)
  	end
  	#--------------------------------------------------------------------------
  	# * modifie les coordonnées
  	#--------------------------------------------------------------------------
  	def modify_coord(x, y, width, height)
  		@x, @y, @width, @height = x, y, width, height 
  		@raw_x, @raw_y = @x, @y
  	end
  	#--------------------------------------------------------------------------
  	# * Met a jours la zone
  	#--------------------------------------------------------------------------
  	def update
  		@x = @raw_x - ($game_map.display_x * 32)
  		@y = @raw_y - ($game_map.display_y * 32)
  	end
  	#--------------------------------------------------------------------------
  	# * vérifie si des coordonnées sont dans une zone
  	#--------------------------------------------------------------------------
  	def in_zone?(x, y)
  		w = ((x.to_f-@x.to_f)**2.0)/(@width.to_f/2.0)
		h = ((y.to_f-@y.to_f)**2.0)/(@height.to_f/2.0)
		w + h <= 1
  	end
end


#==============================================================================
# ** Polygon_Zone
#------------------------------------------------------------------------------
#  Définition de zone polygonale
#==============================================================================

class Polygon_Zone
	#--------------------------------------------------------------------------
	# * Constructeur
	#--------------------------------------------------------------------------
	def initialize(points)
		modify_coord(points)
	end
	#--------------------------------------------------------------------------
	# * modifie les coordonnées
	#--------------------------------------------------------------------------
	def modify_coord(points)
		@points = points
		@last_x = @last_y = 0
	end
	#--------------------------------------------------------------------------
	# * Mise a jours de la zone
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
	# * Trouve  la fonction d'intersection de segments
	#--------------------------------------------------------------------------
	def intersectsegment(a_x, a_y, b_x, b_y, i_x, i_y, p_x, p_y)
		d_x, d_y = b_x - a_x, b_y - a_y
		e_x, e_y = p_x - i_x, p_y - i_y
		denominateur = (d_x * e_y) - (d_y * e_x)
		return -1 if denominateur == 0
		t = (i_x*e_y+e_x*a_y-a_x*e_y-e_x*i_y) / denominateur
		return 0 if t < 0 || t >= 1
		u = (d_x*a_y-d_x*i_y-d_y*a_x+d_y*i_x) / denominateur
		return 0 if u < 0 || u >= 1
		return 1
	end
	#--------------------------------------------------------------------------
	# * Vérifie si un point est dans la zone
	#--------------------------------------------------------------------------
	def in_zone?(p_x, p_y)
		i_x, i_y = 10000 + rand(100), 10000 + rand(100)
		nb_intersections = 0
		@points.each_index do |index|
			a_x, a_y = *@points[index]
			b_x, b_y = *@points[(index + 1) % @points.length]
			intersection = intersectsegment(a_x, a_y, b_x, b_y, i_x, i_y, p_x, p_y)
			return in_zone?(p_x, p_y) if intersection == -1
			nb_intersections += intersection
		end
		return (nb_intersections%2 == 1)
	end
end


#==============================================================================
# ** HWND
#------------------------------------------------------------------------------
#  Librairie de manipulation de fenêtres
#==============================================================================

module HWND
  #--------------------------------------------------------------------------
  # * Constantes
  #--------------------------------------------------------------------------
  FindWindowA = Win32API.new('user32', 'FindWindowA', 'pp', 'l')
  GetPrivateProfileStringA = Win32API.new('kernel32', 'GetPrivateProfileStringA', 'pppplp', 'l')
  ShowCursor = Win32API.new('user32', 'ShowCursor', 'i', 'i')
  #--------------------------------------------------------------------------
  # * Lie les méthodes a la classe
  #--------------------------------------------------------------------------
  extend self
  #--------------------------------------------------------------------------
  # * Retourne le HWND RM
  #--------------------------------------------------------------------------
  def get
    name = "\x00" * 256
    GetPrivateProfileStringA.('Game', 'Title', '', name, 255, ".\\Game.ini")
    name.delete!("\x00")
    return FindWindowA.('RGSS Player', name)
  end
  #--------------------------------------------------------------------------
  # * Défini l'affichage du curseur
  #--------------------------------------------------------------------------
  def show_cursor(flag = true)
    value = flag ? 1 : 0
    ShowCursor.(value)
  end
end

#==============================================================================
# ** Mouse
#------------------------------------------------------------------------------
#  Librairie de fonctionnalités pour la souris
#==============================================================================

module Mouse
  #--------------------------------------------------------------------------
  # * Constantes
  #--------------------------------------------------------------------------
  GetCursorPos = Win32API.new('user32', 'GetCursorPos', 'p', 'i')
  ScreenToClient = Win32API.new('user32', 'ScreenToClient', %w(l p), 'i')
  #--------------------------------------------------------------------------
  # * Lie les méthodes a la classe
  #--------------------------------------------------------------------------
  extend self
  #--------------------------------------------------------------------------
  # * Retourne la position de la souris
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
#  Liste des touches utilisables
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
		# * Vérifie si il click il y a (pour Souris)
		#--------------------------------------------------------------------------
		def click?(key)
			return GetKeyState.(key) > 1
		end
		#--------------------------------------------------------------------------
		# * Vérifie si une touche est pressée
		#--------------------------------------------------------------------------
		def press?(key)
			GetAsyncKeyState.(key) & 0x01 == 1
		end
	end
	#--------------------------------------------------------------------------
	# * Liste des touches
	#--------------------------------------------------------------------------
	# Touches de controles
	MOUSE_LEFT	= 0x01
	MOUSE_RIGHT	= 0x02
	BACKSPACE	= 0x08
	TAB 		= 0x09
	CLEAR		= 0x0C
	ENTER		= 0x0D
	SHIFT		= 0x10
	CTRL		= 0x11
	ALT 		= 0x12
	PAUSE		= 0x13
	CAPS_LOCK	= 0x14
	ESC 		= 0x1B
	SPACE		= 0x20
	PAGE_UP		= 0x22
	ENDKEY		= 0x23
	HOME		= 0x24
	LEFT 		= 0x25
	UP 			= 0x26
	RIGHT    	= 0x27
	DOWN		= 0x28
	SELECT		= 0x29
	PRINT		= 0x2A
	EXECUTE		= 0x2B
	HELP		= 0x2F
	#Touches numériques
	ZERO		= 0x30
	ONE 		= 0x31
	TWO			= 0x32
	THREE		= 0x33
	FOUR		= 0x34
	FIVE		= 0x35
	SIX 		= 0x36
	SEVEN 		= 0x37
	EIGHT		= 0x38
	NINE 		= 0x39
	#Touches de lettres
	A 			= 0x41
	B 			= 0x42
	C 			= 0x43
	D 			= 0x44
	E   		= 0x45
	F 			= 0x46
	G 			= 0x47
	H 			= 0x48
	I 			= 0x49
	J 			= 0x4A
	K 			= 0x4B
	L 			= 0x4C
	M   		= 0x4D
	N 			= 0x4E
	O 			= 0x4F
	P 			= 0x50
	Q			= 0x51
	R 			= 0x52
	S 			= 0x53
	T  			= 0x54
	U 			= 0x55
	V 			= 0x56
	W 			= 0x57
	X 			= 0x58
	Y 			= 0x59
	Z 	 		= 0x5A
	#Touches relative a Windows
	LWINDOW		= 0x5B	
	RWINDOW		= 0x5C
	APPS		= 0x5D
	# Numeripad
	NUM_ZERO	= 0x60
	NUM_ONE		= 0x61
	NUM_TWO		= 0x62
	NUM_THREE	= 0x63
	NUM_FOR		= 0x64
	NUM_FIVE	= 0x65
	NUM_SIX		= 0x66
	NUM_SEVEN	= 0x67
	NUM_EIGHT	= 0x68
	NUM_NINE	= 0x69
	MULTIPLY	= 0x6A
	ADD			= 0x6B
	SEPARATOR	= 0x6C
	SUBSTRACT	= 0x6D
	DECIMAL		= 0x6E
	DIVIDE		= 0x6F
	#Les touches F ^^
	F1			= 0x70
	F2			= 0x71
	F3			= 0x72
	F4			= 0x73
	F5			= 0x74
	F6			= 0x75
	F7			= 0x76
	F8			= 0x77
	F9			= 0x78
	F10			= 0x79
	F11			= 0x7A
	F12			= 0x7B
	#Touches de contrôles
	NUM_LOCK	= 0x90
	SCROLL		= 0x91
	LSHIFT		= 0xA0
	RSHIFT		= 0xA1
	LCONTROL	= 0xA2
	RCONTROL	= 0xA3
	LMENU		= 0xA4
	RMENU		= 0xA5
end

#==============================================================================
# ** Socket
#------------------------------------------------------------------------------
#  Ajoute la possibilité d'envoyer/recevoir des messages à un serveur
#  Un tout grand merci à Zeus81 (et un peu à Nuki tout de même)
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
	# * Constantes
	#--------------------------------------------------------------------------
	AF_INET = 2
	SOCK_STREAM = 1
	#--------------------------------------------------------------------------
	# * Singleton
	#--------------------------------------------------------------------------
	class << self
		#--------------------------------------------------------------------------
		# * Création du SOCKADDR_IN
		#--------------------------------------------------------------------------
		def sockaddr_in(host, port)
			sin_family = AF_INET
			sin_port = Htons.(port)
			in_addr = Inet_addr.(host)
			sockaddr_in = [sin_family, sin_port, in_addr].pack('sSLx8')
			return sockaddr_in
		end
		#--------------------------------------------------------------------------
		# * Création du Socket
		#--------------------------------------------------------------------------
		def socket() return Socket.(AF_INET, SOCK_STREAM, 0) end
		#--------------------------------------------------------------------------
		# * Connexion
		#--------------------------------------------------------------------------
		def connect_sock(sock, sockaddr)
			if Connect.(sock, sockaddr, sockaddr.size) == -1
				p "Impossible de se connecter"
				return
			end
			p "Connexion réussie"
		end
		#--------------------------------------------------------------------------
		# * Connexion
		#--------------------------------------------------------------------------
		def connect(host = "127.0.0.1", port = 9999)
			sockaddr = sockaddr_in(host, port)
			sock = socket()
			connect_sock(sock, sockaddr)
			return sock
		end
		#--------------------------------------------------------------------------
		# * Envoi d'une donnée
		#--------------------------------------------------------------------------
		def send(socket, data)
			value = Send.(socket, data, data.length, 0)
			if value == -1
				p "Envoi échoué"
				shutdown(socket, 2)
				return false
			end
			p "Envoi réussis"
			return true
		end
		#--------------------------------------------------------------------------
		# * Réceptions de données
		#--------------------------------------------------------------------------
		def recv(socket, len = 256)
			buffer = [].pack('x'+len.to_s)
			value = Recv.(socket, buffer, len, 0)
			return buffer.gsub(/\x00/, "") if value != -1
			return false
		end
		#--------------------------------------------------------------------------
		# * Supprime l'émission
		#--------------------------------------------------------------------------
		def shutdown(socket, how) Shutdown.(socket, how) end
		#--------------------------------------------------------------------------
		# * Ferme la connection
		#--------------------------------------------------------------------------
		def close(socket) Close.(socket) end
	end
end

#==============================================================================
# ** Game_Picture
#------------------------------------------------------------------------------
#  Modifie les droits de lectures
#==============================================================================

class Game_Picture
	#--------------------------------------------------------------------------
	# * Public Instance Variables
	#--------------------------------------------------------------------------
	attr_accessor :opacity, :zoom_x, :zoom_y, :x, :y, :blend_type, :tone, :origin, :angle
end

#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  Permet de fixer une picture sur la carte
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # * Alias
  #--------------------------------------------------------------------------
  alias fix_setup setup
  alias fix_initialize initialize
  #--------------------------------------------------------------------------
  # * Variables d'instances
  #--------------------------------------------------------------------------
  attr_accessor :fix_pictures
  attr_accessor :stay_pictures
  #--------------------------------------------------------------------------
  # * Constructeur
  #--------------------------------------------------------------------------
  def initialize
    fix_initialize
    @stay_pictures = []
  end
  #--------------------------------------------------------------------------
  # * Setup
  #--------------------------------------------------------------------------
  def setup(map_id)
    fix_setup(map_id)
    (1..20).each do |id|
      if @screen.pictures[id]
        @screen.pictures[id].erase unless stayed?(id)
      end
    end
    @fix_pictures = []
  end
  #--------------------------------------------------------------------------
  # * Définis les images fixée
  #--------------------------------------------------------------------------
  def set_fixed_pictures(ids)
    @fix_pictures = ids
  end
  #--------------------------------------------------------------------------
  # * Ajoute une image qui reste malgré le téléport
  #--------------------------------------------------------------------------
  def add_stay_pictures(ids)
    @stay_pictures += ids
    @stay_pictures.uniq!
  end
  #--------------------------------------------------------------------------
  # * Enlève une image qui reste malgré le téléport
  #--------------------------------------------------------------------------
  def remove_stay_pictures(ids)
    ids.each do |id|
      @stay_pictures.delete(id)
    end
  end
  #--------------------------------------------------------------------------
  # * Vérifie si une image est fixée
  #--------------------------------------------------------------------------
  def fixed?(id)
    @fix_pictures.include?(id)
  end
  #--------------------------------------------------------------------------
  # * Vérifie si une image reste
  #--------------------------------------------------------------------------
  def stayed?(id)
    @stay_pictures.include?(id)
  end
end

#==============================================================================
# ** Sprite_Picture
#------------------------------------------------------------------------------
#  This sprite is used to display pictures. It observes an instance of the
# Game_Picture class and automatically changes sprite states.
#==============================================================================

class Sprite_Picture
  #--------------------------------------------------------------------------
  # * alias
  #--------------------------------------------------------------------------
  alias fix_initialize initialize
  alias fix_update_position update_position
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :anchor
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     picture : Game_Picture
  #--------------------------------------------------------------------------
  def initialize(viewport, picture)
    fix_initialize(viewport, picture)
    @anchor = (@picture.name =~ /^FIX\-/) != nil
  end
  #--------------------------------------------------------------------------
  # * Update Position
  #--------------------------------------------------------------------------
  def update_position
    @anchor = (@picture.name =~ /^FIX\-/) != nil || $game_map.fixed?(@picture.number)
    if @anchor
      new_x =  @picture.x - ($game_map.display_x * 32)
      new_y =  @picture.y - ($game_map.display_y * 32)
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
#  Utilitaire de manipulation de pictures
#==============================================================================

module Picture
	extend self
	#--------------------------------------------------------------------------
	# * Donne l'écran
	#--------------------------------------------------------------------------
	def get_screen
		$game_map.respond_to?(:screen) ? $game_map.screen : $game_screen
	end
	#--------------------------------------------------------------------------
	# * Change l'opacité
	#--------------------------------------------------------------------------
	def change_opacity(id, value)
		value %=256
		get_screen.pictures[id].opacity = value
	end
	#--------------------------------------------------------------------------
	# * Change le zoom
	#--------------------------------------------------------------------------
	def change_zoom(id, val_x, val_y)
		val_x = val_x.abs
		val_y = val_y.abs
		get_screen.pictures[id].zoom_x = val_x
		get_screen.pictures[id].zoom_y = val_y
	end
	#--------------------------------------------------------------------------
	# * Change le ton
	#--------------------------------------------------------------------------
	def change_tone(id, r, v, b, g=0)
		r, v, b, g = r%256, v%256, b%256, g%256
		get_screen.pictures[id].tone = Tone.new(r,v,b,g)
	end
	#--------------------------------------------------------------------------
	# * Change l'angle
	#--------------------------------------------------------------------------
	def change_angle(id, angle)
		get_screen.pictures[id].angle = angle%360
	end
end

#==============================================================================
# ** Line
#------------------------------------------------------------------------------
#  Défini une ligne
#==============================================================================

class Line
	#--------------------------------------------------------------------------
	# * Public Instance Variables
	#--------------------------------------------------------------------------
	attr_accessor :sx, :sy, :cx, :cy
	#--------------------------------------------------------------------------
	# * Constructeur
	#--------------------------------------------------------------------------
	def initialize(x1,y1,x2,y2)
		@sx, @sy, @cx, @cy = x1, y1, x2, y2
		if @sx != @cx
			@a = (@sy-@cy)/(@sx-@cx).to_f
			@b = (@sy - @sx*@a).to_f
		end
	end
	#--------------------------------------------------------------------------
	# * donne l'équation de droite
	#--------------------------------------------------------------------------
	def equation
		return nil if @sx == @cx
  		fun = lambda{|ap, bp, x|ap*x + bp}
  		return fun.curry.(@a, @b)
	end
	#--------------------------------------------------------------------------
	# * Donne le Y pour un x donné
	#--------------------------------------------------------------------------
	def [](x)
		return nil if @cx == @sx
		return (@a * x + @b)
	end
	#--------------------------------------------------------------------------
	# * vérifie la position d'un point par rapport a une droite
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
#  Ajoute des commandes facilement manipulables
#==============================================================================

module Command
	#--------------------------------------------------------------------------
	# * Singleton de Command
	#--------------------------------------------------------------------------
	extend self
	#--------------------------------------------------------------------------
	# * Opérandes standards
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
	# * Outils de manipulation de droite
	#--------------------------------------------------------------------------
	def line(sx, sy, cx, cy) Line.new(sx, sy, cx, cy) end
	#--------------------------------------------------------------------------
	# * Opérandes de partie
	#--------------------------------------------------------------------------
	def team_size() $game_party.members.size end
	def gold() $game_party.gold end
	def steps() $game_party.steps end
	def play_time() (Graphics.frame_count / Graphics.frame_rate) end
	def timer() $game_timer.sec end
	def save_count() $game_system.save_count end
	def battle_count() $game_system.battle_count end
	#--------------------------------------------------------------------------
	# * Opérandes d'objets
	#--------------------------------------------------------------------------
	def item_count(id) $game_party.item_number($data_items[id]) end
	def weapon_count(id) $game_party.item_number($data_weapons[id]) end
	def armor_count(id) $game_party.item_number($data_armors[id]) end
	#--------------------------------------------------------------------------
	# * Opérandes d'acteurs
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
	# * Opérandes d'events
	#--------------------------------------------------------------------------
	def event_x(id) 
		character = gp
		character = $game_map.events[id] unless id == 0
		character.x
	end
	def event_y(id) 
		character = gp
		character = $game_map.events[id] unless id == 0
		character.y
	end
	def event_direction(id) 
		character = gp
		character = $game_map.events[id] unless id == 0
		character.direction
	end
	def event_screen_x(id) 
		character = gp
		character = $game_map.events[id] unless id == 0
		character.screen_x
	end
	def event_screen_y(id) 
		character = gp
		character = $game_map.events[id] unless id == 0
		character.screen_y
	end
	def heroes_x() Command.event_x(0) end
	def heroes_y() Command.event_y(0) end
	def heroes_direction() Command.event_direction(0) end
	def heroes_screen_x() Command.event_screen_x(0) end
	def heroes_screen_y() Command.event_screen_y(0) end
	def distance_between_case(ev1, ev2)
		event1 = (ev1 == 0) ? gp : $game_map.events[ev1]
		event2 = (ev2 == 0) ? gp : $game_map.events[ev2]
		Math.hypot((event1.x - event2.x), (event1.y-event2.y))
	end
	def distance_between_pixel(ev1, ev2)
		event1 = (ev1 == 0) ? gp : $game_map.events[ev1]
		event2 = (ev2 == 0) ? gp : $game_map.events[ev2]
		Math.hypot((event1.screen_x - event2.screen_x), (event1.screen_y-event2.screen_y))
	end
	#--------------------------------------------------------------------------
	# * Opérandes de partie
	#--------------------------------------------------------------------------
	def actor_id(position) 
		$game_party.members[position]
		return actor ? actor.id : 0
	end
	#--------------------------------------------------------------------------
	# * Commande de lecture de la base de données
	#--------------------------------------------------------------------------
	def read_data_monster(id, method = false)
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
	# * Manipulation des zones
	#--------------------------------------------------------------------------
	def create_zone(*args)
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
	# * Manipulation des images
	#--------------------------------------------------------------------------
	def picture_opacity(id, value) Picture.change_opacity(id, value) end
	def picture_angle(id, value) Picture.change_angle(id, value) end
	def picture_zoom(id, value_x, value_y) Picture.change_zoom(id, value_x, value_y) end
	def picture_tone(id, r, v, b, g=0) Picture.change_tone(id, r, v, b, g) end
	def define_fix_picture(*ids) $game_map.set_fixed_pictures(ids) end
	def add_stay_pictures(*ids) $game_map.add_stay_pictures(ids) end
	def remove_stay_pictures(*ids) $game_map.remove_stay_pictures(ids) end
	#--------------------------------------------------------------------------
	# * Manipulation des sauvegardes
	#--------------------------------------------------------------------------
	def save_game(index) DataManager.save_game(index) end
	def load_game(index) DataManager.load_game(index) end
	def save_exists?(index) DataManager.save_file_exists? end
	def delete_save(index) DataManager.delete_save_file(index) end
	#--------------------------------------------------------------------------
	# * Manipulation de devices
	#--------------------------------------------------------------------------
	def get_mouse_x() Mouse.position[:x] end
	def get_mouse_y() Mouse.position[:y] end
	def mouse_click?(key) Key.click?(key) end
	def key_press?(key) Key.press?(key) end
	def erase_cursor() HWND.show_cursor(false) end
	#--------------------------------------------------------------------------
	# * Manipulation de la base de données alternative
	#--------------------------------------------------------------------------
	def table(name)
		$game_system.database.find do |elt|
			elt.name == name
		end
	end
	#--------------------------------------------------------------------------
	# * Manipulation des Sockets
	#--------------------------------------------------------------------------
	def connect(host, port) Socket.connect(host, port) end
	def send_to_server(socket, value) Socket.send(socket, value) end
	def recv_to_server(socket, len = 256) Socket.recv(socket, len) end
	def wait_for_recv(socket, len = 256)
		flag = false
		flag = Socket.recv(socket, len) while !flag
		return flag
	end
end

#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  Ajout du support des variables locales
#==============================================================================

class Game_Interpreter
	#--------------------------------------------------------------------------
	# * Récupération d'une variable local
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
	# * Attribution d'une variable locale
	#--------------------------------------------------------------------------
	def set(*arguments)
		case arguments.length
		when 2; $game_selfVars[@map_id, @event_id, arguments[0]] = arguments[1]
		when 3; $game_selfVars[@map_id, arguments[0], arguments[1]] = arguments[2]
		when 4; $game_selfVars[arguments[0], arguments[1], arguments[2]] = arguments[3]
		end
	end
	#--------------------------------------------------------------------------
	# * API de manipulation des commandes
	#--------------------------------------------------------------------------
	def cmd(command, *arguments) Command.send(command.to_sym, *arguments) end
	#--------------------------------------------------------------------------
	# * Alias de cmd
	#--------------------------------------------------------------------------
	alias command cmd
	alias c cmd
	#--------------------------------------------------------------------------
	# * API de manipulation des variables
	#--------------------------------------------------------------------------
	def variable(id, value) $game_variables[id] = value end
	#--------------------------------------------------------------------------
	# * API de récupérations des monstres/acteurs/techniques/tables
	#--------------------------------------------------------------------------
	def ennemy(id) cmd(:read_data_monster, id) end
	def actor(id) cmd(:actor, id) end
	def skill(id) cmd(:read_data_skill, id) end
	def table(name)cmd(:table, name) end
end

#==============================================================================
# ** Game_System
#------------------------------------------------------------------------------
#  This class handles system data. It saves the disable state of saving and 
# menus. Instances of this class are referenced by $game_system.
#==============================================================================

class Game_System
	#--------------------------------------------------------------------------
	# * Variables d'instances
	#--------------------------------------------------------------------------
	attr_reader :database
	#--------------------------------------------------------------------------
	# * Alias
	#--------------------------------------------------------------------------
	alias local_initialize initialize
	#--------------------------------------------------------------------------
	# * Constructeur
	#--------------------------------------------------------------------------
	def initialize
		local_initialize
		@database = Database.finalize
	end
end

#==============================================================================
# ** DataManager
#------------------------------------------------------------------------------
#  Ajout des variables locales
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
		# * Crée les objets du jeu
		#--------------------------------------------------------------------------
		def create_game_objects
			local_create_game_objects
			$game_selfVars = Simple_Matrix.new
		end
		#--------------------------------------------------------------------------
		# * Sauve le contenu du jeu
		#--------------------------------------------------------------------------
		def make_save_contents
			contents = local_make_save_contents
			contents[:self_vars] = $game_selfVars
			contents
		end
		#--------------------------------------------------------------------------
		# * Charge le contenu du jeu
		#--------------------------------------------------------------------------
		def extract_save_contents(contents)
			local_extract_save_contents
			$game_selfVars = contents[:self_vars]
		end
	end
end

#==============================================================================
# ** Kernel
#------------------------------------------------------------------------------
#  Ajoute la fonction "cmd" pour être utlisable en scriptant
#==============================================================================

module Kernel
	#--------------------------------------------------------------------------
	# * API de manipulation des tables
	#--------------------------------------------------------------------------
	def table(name) Command.table("name") end
	#--------------------------------------------------------------------------
	# * API de manipulation des commandes
	#--------------------------------------------------------------------------
	def cmd(command, *arguments) Command.send(command.to_sym, *arguments) end
	#--------------------------------------------------------------------------
	# * Alias de cmd
	#--------------------------------------------------------------------------
	alias command cmd
	alias c cmd
end