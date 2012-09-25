=begin
		Modificateur de teinte inGame ! 
		------------------------------------------------------
		Par Grim (http://blog.gri.im)
		Funkywork - Biloucorp

		Un tout grand merci à Zeus81 pour sa précieuse aide (sur les arguments
		et pour le 'v' :P)

		Idée originale de Siegfried, merci à lui ! 

		Merci à Magicalichigo et Nuki pour leur aide aussi :)

		Concept
		------------------------------------------------------
		Je suis un grand utilisateur des tons d'écran sous RM, 
		le problème c'est que l'on est jamais satisfait du premier coup
		donc il faut recompiler le projet plusieurs fois...
		Avec ce script, vous avez, en mode test (donc uniquement lancé
		depuis l'éditeur) une fenêtre de test des teintes en temps réel.
		La touche pour appeller/masquer la fenêtre est F3 par défaut,
		Vous pouvez la changer via le module Tint_Config, il suffit 
		de modifier la constante KEY.

		J'espère que ce script sera utile ! 

=end
#==============================================================================
# ** Tint_Config
#------------------------------------------------------------------------------
#  Configuration du script
#==============================================================================

module Tint_Config
	#--------------------------------------------------------------------------
	# * Liste des touches
	#--------------------------------------------------------------------------
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
	#--------------------------------------------------------------------------
	# * Touche d'activation du menu de teinte
	#--------------------------------------------------------------------------
	KEY = F3
end

#==============================================================================
# ** Module d'interaction Utilisateur
#------------------------------------------------------------------------------
#  Ensemble des outils de saisie utilisateur
#==============================================================================

module GUI
	#--------------------------------------------------------------------------
	# * Librairies
	#--------------------------------------------------------------------------
	FindWindowA = Win32API.new('user32', 'FindWindowA', 'pp', 'l')
	GetPrivateProfileStringA = Win32API.new('kernel32', 'GetPrivateProfileStringA', 'pppplp', 'l')
	GetWindowRect = Win32API.new('user32','GetWindowRect','lp','i')
	ScreenToClient = Win32API.new('user32', 'ScreenToClient', 'lp', 'i')
	GetAsyncKeyState = Win32API.new('user32', 'GetAsyncKeyState', 'i', 'i')
	CreateWindowEx = Win32API.new("user32","CreateWindowEx",'lpplllllllll','l')
	ShowWindow = Win32API.new('user32','ShowWindow','ll','l')
	DestroyWindow = Win32API.new('user32','DestroyWindow','p','l')
	MoveWindow = Win32API.new('user32','MoveWindow','liiiil','l')
	SendMessage = Win32API.new('user32','SendMessage','llll','l') 
	SetWindowText = Win32API.new('user32','SetWindowText','pp','i')
	#--------------------------------------------------------------------------
	# * Styles
	#--------------------------------------------------------------------------
	WS_BORDER = 0x00800000
	WS_POPUP = 0x80000000
	WS_VISIBLE = 0x10000000
	WS_SYSMENU = 0x00080000
	WS_CLIPSIBLINGS = 0x04000000
	WS_CAPTION = 0x00C00000
	WS_TILED = 0x00000000
	WS_DLGFRAME = 0x00400000
	WS_CHILD = 0x40000000
	WS_EX_WINDOW_EDGE = 0x00000100
	WS_EX_APPWINDOW = 0x00040000
	WS_EX_TOOLWINDOW = 0x00000080
	TBS_AUTOTICKS = 1
	TBS_ENABLESELRANGE = 32
	TBS_NOTIFY  = 0x0001
	TBM_SETRANGE = 1030
	TBM_SETPOS = 1029
	TBM_GETPOS = 1024
	TBM_GETMAX = 1031
	TRACKBAR_CLASS = "msctls_trackbar32"

	#--------------------------------------------------------------------------
	# * Singleton
	#--------------------------------------------------------------------------
	class << self
		#--------------------------------------------------------------------------
		# * Retourne la fenêtre RGSS
		#--------------------------------------------------------------------------
		def handle
			name = [].pack("x256")
			GetPrivateProfileStringA.('Game', 'Title', '', name, 255, ".\\Game.ini")
			name.delete!("\x00")
			FindWindowA.('RGSS Player', name)
		end
		#--------------------------------------------------------------------------
		# * Retourne le RECT de la fenêtre sur l'écran
		#--------------------------------------------------------------------------
		def window_rect
			buffer = [0,0,0,0].pack('l4')
			GetWindowRect.(handle, buffer)
			return Rect.new(*buffer.unpack('l4'))
		end
	end

	#==============================================================================
	# ** Window_Track
	#------------------------------------------------------------------------------
	#  Fenêtre qui contiendra les sliders
	#==============================================================================

	class Window_Track
		#--------------------------------------------------------------------------
		# * Variable de classe
		#--------------------------------------------------------------------------
		@@HWND = GUI.handle
		#--------------------------------------------------------------------------
		# * variables d'instances
		#--------------------------------------------------------------------------
		attr_accessor :r, :g, :b, :gr
		attr_reader :visibility
		#--------------------------------------------------------------------------
		# * Constructeur
		#--------------------------------------------------------------------------
		def initialize(r=0,v=0,b=0,g=-255)
			@visibility = false
			name = "Modification de la teinte"
			@w, @h = 280, 200
			@x, @y = GUI.window_rect.x-@w-16, GUI.window_rect.y
			ex_style = WS_EX_WINDOW_EDGE|WS_EX_APPWINDOW|WS_EX_TOOLWINDOW
			dw_style = WS_POPUP|WS_DLGFRAME|WS_TILED|WS_CAPTION
			args = [ex_style, "static", name, dw_style, @x,@y,@w,@h, @@HWND, 0,0,0]
			@window = CreateWindowEx.(*args)
			@r, @g, @b, @gr = r, v, b, g
			args2 = [0, "static", "[R: #{r}] [V: #{v}] [B: #{b}] [G: #{g}]", WS_CHILD|WS_VISIBLE,10,150,260,40, @window, 0,0,0]
			@text = CreateWindowEx.(*args2)
			@red = UI_Slider.new("red", 10, 32, @window, r)
			@green = UI_Slider.new("green", 10, 64, @window, v)
			@blue = UI_Slider.new("blue", 10, 96, @window, b)
			@gray = UI_Slider.new("gray", 10, 128, @window, g)
		end
		#--------------------------------------------------------------------------
		# * Get value
		#--------------------------------------------------------------------------
		def get_value(sym)
			return @red.get_value if sym == :red || sym == :r
			return @green.get_value if sym == :green || sym == :g
			return @blue.get_value if sym == :blue || sym == :b
			return @gray.get_value
		end
		#--------------------------------------------------------------------------
		# * Delete
		#--------------------------------------------------------------------------
		def delete
			DestroyWindow.(@window)
		end
		#--------------------------------------------------------------------------
		# * Display textbox
		#--------------------------------------------------------------------------
		def set_visibility(value, r=0, v=0, b=0, g=-255)
			@visibility = !!value
			flag = (value) ? 1 : 0
			@red.set_value r
			@green.set_value v
			@blue.set_value b
			@gray.set_value g
			@r, @g, @b, @gr = r, v, b, g
			ShowWindow.(@window, flag)
			set_text r, v, b, g
		end
		#--------------------------------------------------------------------------
		# * set text
		#--------------------------------------------------------------------------
		def set_text(r, v, b, g)
			SetWindowText.(@text, "[R: #{r}] [V: #{v}] [B: #{b}] [G: #{g}]")
		end
	end

	#==============================================================================
	# ** UI_Slider
	#------------------------------------------------------------------------------
	#  Décris un slider
	#==============================================================================

	class UI_Slider
		#--------------------------------------------------------------------------
		# * Constructeur
		#--------------------------------------------------------------------------
		def initialize(name, x, y, hwnd, value)
			@hwnd = hwnd
			dw_style = WS_CHILD|WS_VISIBLE|TBS_NOTIFY
			args = [0, TRACKBAR_CLASS, name, dw_style, x, y, 255, 32, @hwnd, 0,0,0]
			@track = CreateWindowEx.(*args)
			SendMessage.(@track, TBM_SETRANGE, 1, [-255, 255].pack('SS').unpack('L')[0])
			SendMessage.(@track, TBM_SETPOS, 1, value)
		end
		#--------------------------------------------------------------------------
		# * Get Value
		#--------------------------------------------------------------------------
		def get_value
			return SendMessage.(@track, TBM_GETPOS, 0, 0)
		end
		#--------------------------------------------------------------------------
		# * Set Value
		#--------------------------------------------------------------------------
		def set_value(val)
			return SendMessage.(@track, TBM_SETPOS, 1, val)
		end
	end
end

#==============================================================================
# ** Module Input
#------------------------------------------------------------------------------
#  Ajout de la gestion de la Palette
#==============================================================================

module Input
	#--------------------------------------------------------------------------
	# * variables de classe
	#--------------------------------------------------------------------------
	@@window_Track = GUI::Window_Track.new
	#--------------------------------------------------------------------------
	# * Singleton
	#--------------------------------------------------------------------------
	class << self
		#--------------------------------------------------------------------------
		# * Alias
		#--------------------------------------------------------------------------
		alias tint_update update
		#--------------------------------------------------------------------------
		# * Input update
		#--------------------------------------------------------------------------
		def update
			tint_update
			if $TEST && SceneManager.scene.is_a?(Scene_Map)
				t = $game_map.screen.tone
				if GUI::GetAsyncKeyState.(Tint_Config::KEY)&0x01 == 1
					@@window_Track.set_visibility(!@@window_Track.visibility, t.red, t.green, t.blue, t.gray)
				end
				r, v, b, g = @@window_Track.get_value(:r), @@window_Track.get_value(:g),@@window_Track.get_value(:b), @@window_Track.get_value(:gr)
				r_check = t.red != r
				g_check = t.green != v
				b_check = t.green != b
				gr_check = t.gray != g
				if (r_check || g_check || b_check || gr_check) && @@window_Track.visibility
					new_tone = Tone.new(r,v,b,g)
					$game_map.screen.start_tone_change(new_tone, 0)
					@@window_Track.set_text(r,v,b,g)
				end
			end
		end
	end
end