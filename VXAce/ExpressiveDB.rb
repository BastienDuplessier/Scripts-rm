#==============================================================================
# ** Extension de base de données expressive
# Par Grim 
# Un tout grand merci à Molok, Hiino et Zangther
# http://biloucorp.com | http://funkywork.blogspot.com
#------------------------------------------------------------------------------
# Cette version s'utilise de la même manière que l'ancienne, sauf que la 
# création de table passe par la définition d'une classe héritante de Table.
# Par exemple:

=begin

	class Weapon < Table
		field :id, :int
		field :nom, :string
		field :prix, :float
	end

	# Pour remplire la base de données, il suffit de faire des instances.
	# Par exemple:

	Weapon.new(id: 1, name: "Epée dark 1", prix: 101.0)
	Weapon.new(id: 2, name: "Epée dark 2", prix: 102.0)
	Weapon.new(id: 3, name: "Epée dark 3", prix: 103.0)
	
=end

# Ensuite elle s'utilise de la même manière que l'ancienne.
# L'avantage de cette version et qu'elle permet d'implémenter directement des
# méthodes aux tables.
# Elle est cependant réservé à des utilisateurs avertits :)

#==============================================================================
#==============================================================================
# ** Patch pour l'EventExtender
#------------------------------------------------------------------------------
#==============================================================================
$game_database = {}
#==============================================================================
# ** Field
#------------------------------------------------------------------------------
# Défini un champ dans la base de données
#==============================================================================
class Field
	#--------------------------------------------------------------------------
	# * Singleton
	#--------------------------------------------------------------------------
	class << self
		#--------------------------------------------------------------------------
		# * types disponnibles
		#--------------------------------------------------------------------------
		def types
			[:int, :float, :string, :bool]
		end
		#--------------------------------------------------------------------------
		# * Routine de conversion
		#--------------------------------------------------------------------------
		def cast(value, type)
			result = (value.respond_to?(:to_s)) ? value.to_s : ""
			case type
			when :int; result = (value.respond_to?(:to_i)) ? value.to_i : 0
			when :float; result = (value.respond_to?(:to_f)) ? value.to_f : 0.0
			when :bool; result = !!value
			end
			result
		end
		#--------------------------------------------------------------------------
		# * Vérifie les types
		#--------------------------------------------------------------------------
		def match_type(raw, type)
			return true if raw.is_a?(String) && type == :string
			return true if raw.is_a?(Fixnum) && type == :int
			return true if raw.is_a?(Float) && type == :float
			return true if (raw.is_a?(TrueClass) || raw.is_a?(FalseClass)) && type == :bool
			return false
		end
	end
	#--------------------------------------------------------------------------
	# * Variables d'instances
	#--------------------------------------------------------------------------
	attr_accessor :name, :type
	#--------------------------------------------------------------------------
	# * Constructeur
	#--------------------------------------------------------------------------
	def initialize(name, type)
		@type = :string
		if type.respond_to?(:to_sym)
			@type = type.to_sym
			@type = :string unless Field.types.include?(@type)
		end
		@name = name.to_sym
	end
	#--------------------------------------------------------------------------
	# * Conversion dans un champ donné
	#--------------------------------------------------------------------------
	def adapt(value = 0)
		Field.cast(value, @type)
	end
end

#==============================================================================
# ** Table
#------------------------------------------------------------------------------
# Défini une table de la base de données
#==============================================================================

class Table
	#--------------------------------------------------------------------------
	# * Variables de classe
	#--------------------------------------------------------------------------
	@@fields = []
	#--------------------------------------------------------------------------
	# * Singleton
	#--------------------------------------------------------------------------
	class << self
		#--------------------------------------------------------------------------
		# * Défini un champ dans la base de données
		#--------------------------------------------------------------------------
		def define_field(name, type) @@fields << Field.new(name, type) end
		alias field define_field
	end
	#--------------------------------------------------------------------------
	# * constructeur
	#--------------------------------------------------------------------------
	def initialize(args)
		@@fields.each_with_index do |field, index|
			raise "Type Error" if !Field.match_type(args[field.name], field.type) && $TEST
			self.instance_variable_set("@#{field.name}".to_sym, field.adapt(args[field.name]))
			behaviour_get = lambda{self.instance_variable_get("@#{field.name}".to_sym)}
			behaviour_set = lambda do |arg|
				raise "Type Error" if !Field.match_type(arg, field.type) && $TEST
				self.instance_variable_set("@#{field.name}".to_sym, field.adapt(arg)) 
			end
			self.class.send(:define_method, field.name.to_sym, &behaviour_get)
			self.class.send(:define_method, "#{field.name}=".to_sym, &behaviour_set)
		end
		save_row
	end
	#--------------------------------------------------------------------------
	# * routine d'ajout au conteneur général
	#--------------------------------------------------------------------------
	def save_row
		key = "#{self.class}".to_sym
		$game_database[key] ||= []
		$game_database[key] << self
	end
end

#==============================================================================
# ** Command
#------------------------------------------------------------------------------
# Adds easily usable commands
#==============================================================================

module Command
	extend self
	#--------------------------------------------------------------------------
	# * Alternative database handling
	#--------------------------------------------------------------------------
	def table(name)
		$game_database[name.to_sym] ||= []
		return $game_database[name.to_sym]
	end
end