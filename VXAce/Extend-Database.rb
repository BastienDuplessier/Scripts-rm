# Extend Database ~ Der Botaniker (Nuki)
# http://www.biloucorp.com

# Idea : Avygeil, Grim 
# Thanks to Hiino, Zangther (sex 's motivating)
# And special thanks to larabdubled


#==============================================================================
# ** Object
#------------------------------------------------------------------------------
#  Generic behaviour
#==============================================================================

class Object
  #--------------------------------------------------------------------------
  # * Bool cast
  #--------------------------------------------------------------------------
  if defined?(Command)
    remove_const(:Database)
    def to_bool; (self != nil || self != false) end 
  end
  #--------------------------------------------------------------------------
  # * Polymorphic cast
  #--------------------------------------------------------------------------
  def nothing; self; end
  #--------------------------------------------------------------------------
  # * Get Instance values
  #--------------------------------------------------------------------------
  def instance_values
    instances = Array.new
    instance_variables.each do |i|
      instances << instance_variable_get(i)
    end
    instances
  end
end

#==============================================================================
# ** Database
#------------------------------------------------------------------------------
# Representation of an Abstract Database
#==============================================================================

module Database
  
  #==============================================================================
  # ** Types
  #------------------------------------------------------------------------------
  # Design the Type's System
  #==============================================================================
  
  RPGDatas = [
    "Actors", 
    "Classes",
    "Skills",
    "Items",
    "Weapons",
    "Armors",
    "Enemies",
    "Enemies",
    "States",
    "Animations",
    "Tilesets",
    "CommonEvents",
    "MapInfos"
  ]
  
  module Type
    #--------------------------------------------------------------------------
    # * Type Enum
    #--------------------------------------------------------------------------
    Types = {
      string:       [:to_s, ""],
      integer:      [:to_i, 0],
      float:        [:to_f, 0.0],
      boolean:      [:to_bool, true],
      polymorphic:  [:nothing, ""]
    }
    #--------------------------------------------------------------------------
    # * String's representation
    #--------------------------------------------------------------------------
    def string(field_name)
      handle_field(:string, field_name.to_sym)
    end
    alias :text :string
    #--------------------------------------------------------------------------
    # * Integer's representation
    #--------------------------------------------------------------------------
    def integer(field_name)
      handle_field(:integer, field_name.to_sym)
    end
    alias :int :integer
    #--------------------------------------------------------------------------
    # * String's representation
    #--------------------------------------------------------------------------
    def float(field_name)
      handle_field(:float, field_name.to_sym)
    end
    #--------------------------------------------------------------------------
    # * String's representation
    #--------------------------------------------------------------------------
    def boolean(field_name)
      handle_field(:boolean, field_name.to_sym)
    end
    alias :bool :boolean
    #--------------------------------------------------------------------------
    # * String's representation
    #--------------------------------------------------------------------------
    def polymorphic(field_name)
      handle_field(:polymorphic, field_name.to_sym)
    end
    alias :free :polymorphic
    #--------------------------------------------------------------------------
    # * Type Coercion
    #--------------------------------------------------------------------------
    def self.coercion(className)
      return :integer if className == Fixnum
      return :string if className == String
      return :float if className == Float
      return :boolean if className == TrueClass || className == FalseClass
      :polymorphic
    end
  end
  
  #==============================================================================
  # ** Table
  #------------------------------------------------------------------------------
  # Representation of an Abstract Table
  #==============================================================================  
  
  class Table
    #--------------------------------------------------------------------------
    # * Append Type handler
    #--------------------------------------------------------------------------
    extend Type
    Types = Type::Types
    #--------------------------------------------------------------------------
    # * Singleton of Table
    #--------------------------------------------------------------------------
    class << self
      #--------------------------------------------------------------------------
      # * Public instance variable
      #--------------------------------------------------------------------------
      attr_accessor :fields
      attr_accessor :classname
      #--------------------------------------------------------------------------
      # * Handle Field
      #--------------------------------------------------------------------------
      def handle_field(type, name)
        @classname ||= self.to_s.to_sym
        @fields ||= Hash.new
        @fields[name] = type
        instance_variable_set("@#{name}".to_sym, Types[type][1])
        send(:attr_accessor, name)
      end
      #--------------------------------------------------------------------------
      # * Inline Insertion
      #--------------------------------------------------------------------------
      def insert(*args)
        keys = @fields.keys
        hash = Hash[keys.zip(args)]
        self.new(hash)
      end
    end
    #--------------------------------------------------------------------------
    # * Object initialize
    #--------------------------------------------------------------------------
    def initialize(hash)
      hash.each do |key, value|
        type = self.class.fields[key]
        insertion = Types[type][1]
        insertion = value.send(Types[type][0]) if value.respond_to?(Types[type][0])
        instance_variable_set("@#{key}".to_sym, insertion)
      end
      Database.tables[self.class.classname] ||= Array.new
      Database.tables[self.class.classname] << self
    end
  end
  #--------------------------------------------------------------------------
  # * Singleton of Database
  #--------------------------------------------------------------------------
  class << self
    #--------------------------------------------------------------------------
    # * Public instance variable
    #--------------------------------------------------------------------------
    attr_accessor :tables
    #--------------------------------------------------------------------------
    # * API for tables
    #--------------------------------------------------------------------------
    Database.tables = Hash.new
    #--------------------------------------------------------------------------
    # * Method Missing
    #--------------------------------------------------------------------------
    def method_missing(method, *args)
      tables[method] || (raise(NoMethodError))
    end
  end
end



#==============================================================================
# ** Event Extender 4 Implantation
#==============================================================================
if defined?(Command)
  #==============================================================================
  # ** T
  #------------------------------------------------------------------------------
  #  Database handling API
  #==============================================================================
  
  module T
    #--------------------------------------------------------------------------
    # * Get a table
    #--------------------------------------------------------------------------
    def [](name); Database.tables[name.to_sym]; end
  end
end

#==============================================================================
# ** RPG::Module Mapping
#------------------------------------------------------------------------------
#  Initiale Database Mapping
#==============================================================================

Database::RPGDatas.each do |data|
  rpgStruct = load_data("Data/#{data}.rvdata2")
  instance = rpgStruct.find{|i| !i.nil?}
  instance = instance[1] if instance.is_a?(Array)
  Object.const_set(
    "VXACE_#{data}".to_sym, 
    Class.new(Database::Table) do 
      self.classname = "VXACE_#{data}".to_sym
      instance.instance_variables.each do |attr|
        classData = instance.send(:instance_variable_get, attr).class
        type = Database::Type.coercion(classData)
        self.send(type, attr.to_s[1..-1].to_sym)
      end
      rpgStruct.each do |rpgData|
        rpgData = rpgData[1] if rpgData.is_a?(Hash)
        self.insert(*rpgData.instance_values)
      end
    end
  )
end
