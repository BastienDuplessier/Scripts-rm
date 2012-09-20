# Movie player un petit peu nul par Raho
# Pour lancer un film faites un appel de script
# Movie.play("chemin du film")
# Veillez a avoir un bon encodage et idéalement un film a la taille de votre 
# résolution d'écran... j'ai eu la flemme de faire la position (qui est en plus
# très facile a faire mais bon :D )
#===============================================================================
# ** Movie
#-------------------------------------------------------------------------------
# Outil de lecture
#===============================================================================

module Movie
	#--------------------------------------------------------------------------
	# * Librairies
	#--------------------------------------------------------------------------
	MciSendString = Win32API.new('winmm','mciSendString','ppll','v')
	GetPrivateProfileStringA = Win32API.new('kernel32', 'GetPrivateProfileStringA', 'pppplp', 'l')
	FindWindowA = Win32API.new('user32', 'FindWindowA', 'pp', 'l')
	#--------------------------------------------------------------------------
	# * Multimedia Command Strings
	#--------------------------------------------------------------------------
	Open 	= 	lambda{|name, kind, hwnd| "open #{name} type #{kind} alias MOVIE  style child parent #{hwnd.to_s}"}
	Handle 	= 	lambda{|window|"window TEST handle #{window}"}
	Put 	= 	lambda{|x, y, w, h| "put MOVIE window at #{x} #{y} #{w} #{h}"}
	Play 	= 	lambda{|more|"play MOVIE #{more} notify"}
	Status 	= 	lambda{|type|"status MOVIE #{type} notify"}
	Close 	= 	"close MOVIE notify"
	#--------------------------------------------------------------------------
	# * Retourne la fenêtre
	#--------------------------------------------------------------------------
	def handle
		buffer = [].pack("x256")
		GetPrivateProfileStringA.call('Game','Title','',buffer,255,".\\Game.ini")
		buffer.delete!("\x00")
		return FindWindowA.call('RGSS Player', buffer)
	end
	#--------------------------------------------------------------------------
	# * Méthodes publiques
	#--------------------------------------------------------------------------
	extend self
	#--------------------------------------------------------------------------
	# * Retourne le type en fonction de l'extension
	#--------------------------------------------------------------------------
	def get_type(file)
		type = ""
		case File.extname(file)
		when ".avi"; type = "avivideo"
		when ".mpg"; type = "mpegvideo"
		when ".mpeg"; type = "mpegvideo"
		else
			raise "Mauvaise extension ! "
		end
		type
	end
	#--------------------------------------------------------------------------
	# * Retourne les positions par défaut
	#--------------------------------------------------------------------------
	def default_value
		x, y = "0", "0"
		w, h = "", ""
		return x, y, w, h
	end
	#--------------------------------------------------------------------------
	# * play movie
	#--------------------------------------------------------------------------
	def play(movie)
		buffer = " "*256
		type = get_type(movie)
		MciSendString.call(Open.call(movie, type, self.handle), 0,0,0)
		MciSendString.call(Status.call("ready"), buffer, 256, 0)
		MciSendString.call(Put.call(*default_value), buffer,0,0)
		MciSendString.call(Play.call(""), buffer, 0,0)
		Graphics.freeze
		s_time = Time.now
		loop do
			sleep(0.1)
			MciSendString.call(Status.call("mode"), buffer, 256, 0)
			if buffer.unpack('aaaa') == "stop".split(//)
				sleep(1.0)
				break 
			end
			if Time.now - s_time >= 9
				Graphics.update
				s_time = Time.now
			end
		end
		MciSendString.call(Close, 0,0,handle)
		$scene = Scene_Map.new
	end
end
