=begin
  =============== Typed Entities ===============
  Auteur : S4suk3
  Version : 1
  ==============================================
  Ce script ajoute un accès rapide aux notes dans 
  la base de données et permet une conversion en 
  commandes avec un système de typage (par contraintes)
  ==============================================
  Accèdes à une note : notes(container, id)
  container peut prendre les valeurs : 
   - actors
   - skills
   - classes
   - items
   - armors
   - weapons
   - enemies
   - states
   - tilesets
  Et l'id correspond à l'id (se réferer à la base de données)
  de l'objet dont il faut récupérer la note.
  ==============================================
  Il est possible de convertir une chaine de texte en 
  liste de commande. Les commandes ont deux formes.
  Simple => <nom>valeur</nom>
  Complexe => <nom attributA="valeur", attributB="valeur" />
  Dans la commande complexe, il est possible de spécifier autant 
  d'attributs que vous le désirez.
  Pour convertir une chaine de texte en liste de commande, il suffit 
  de faire votre_chaine.to_cmd_list
  qui retournera un Hash de commande. 
  Et pour accéder à la valeur d'une commande il suffit d'utiliser 
  la clé référante à son nom. Par exemple, si mon commentaire potion 
  est formé comme ceci : 
  <special_price>99.10</special_price>
  <other cout_mp="10" cout_hp="20" cout_autre="30"/>
  Il suffirait de faire ceci pour accéder à ces attributs:
  commande = notes(items, 1).to_cmd_list
  commande["special_price"].value donnera une chaine de texte 99.10
  commande["other"]["cout_hp"].value donnera une chaine de texte 20
  Il est donc possible d'ajouter des contraintes de types aux valeurs.
  Les types possibles sont :int (entier), :float (nombre a virgule)
  :bool (un booléan, true ou false), :string (une chaine de texte)
  :string_list (une liste de chaine, "aha, ohoho, hihih" donnera ["aha", "ohoho", "hihih"]
  soit elle utilise la virgule comme séparateur), :int_list (utilise aussi 
  la virgule comme séparateur), :float_list (utilise aussi la virgule comme séparateur),
  bool_list (utilise aussi la virgule comme séprateur)
  ==============================================================
  donc par exemple, une commande comme ceci :
  <truc>1,2,3,4</truc>
  si je l'appelle (.value), j'aurais une chaine "1,2,3,4".
  Avec les contraintes de types. Reprennons notre exemple potion à qui nous ajoutons 
  une commande:
  <special_price>99.10</special_price>
  <other cout_mp="10" cout_hp="20" cout_autre="30"/>
  <truc>1,2,3,4</truc>
  Si je fais : 
  commande = notes(items, 1).to_cmd_list
  commande["special_price"].coercion(:float)
  commande["truc"].coercion(:int_list)
  commande["other"]["cout_hp"].coercion(:int)
  Les appels de ces valeurs seront typés (en float, liste d'entier et entier).
  =============
  Il est aussi possible d'utiliser .entities pour récupérer une entitée
=end  

#==============================================================================
# ** Entity
#------------------------------------------------------------------------------
# Entity Name-space
#==============================================================================

module Entity
  #--------------------------------------------------------------------------
  # * Type System
  #--------------------------------------------------------------------------
  Types = [
    :int, 
    :integer, 
    :float, 
    :bool, 
    :boolean, 
    :string, 
    :text,
    :int_list,
    :float_list,
    :bool_list,
    :string_list
   ]
  #--------------------------------------------------------------------------
  # * Static context
  #--------------------------------------------------------------------------
  class << self
    #--------------------------------------------------------------------------
    # * Type Conversion
    #--------------------------------------------------------------------------
    def cast(value, type)
      type = :string unless Types.include?(type)
      return value.to_i if [:int, :integer].include?(type)
      return value.to_f if type == :float
      return value.to_bool if [:bool, :boolean].include?(type)
      return value.to_string_list if type == :string_list
      return value.to_int_list if type == :int_list
      return value.to_float_list if type == :float_list
      return value.to_bool_list if type == :bool_list
      value.to_s
    end
    #--------------------------------------------------------------------------
    # * Convert line
    #--------------------------------------------------------------------------
    def convert_line(line)
      if line =~ /^<(\w+)>(.*)<\/\w+>/
        return Simple.new($1, $2)
      else
        content_balise = line =~ /^<(.*)\/>$/ && $1
        return nil unless content_balise
        name, rest = content_balise =~ /^(\w*)/ && [$1, $']
        attributes = build_attributes(rest)
        return Complex.new(name, attributes)
      end
      return nil
    end
    #--------------------------------------------------------------------------
    # * Build Attributes
    #--------------------------------------------------------------------------
    def build_attributes(str, acc = {})
      return acc.select{|k, a|a&&a.keyword&&a.value} if !str || str.empty?
      name, value, rest = str =~ /^\s*(\w+)\s*=\s*\\*"([^\\"]+)\\*"/ && [$1,$2,$']
      acc[name] = Simple.new(name, value)
      build_attributes(rest, acc)
    end
  end
  
  #==============================================================================
  # ** Simple
  #------------------------------------------------------------------------------
  # Representation of a Simple entity
  # model = <keyword>Value</keyword>
  #==============================================================================
  
  class Simple
    #--------------------------------------------------------------------------
    # * Public instances variables
    #--------------------------------------------------------------------------
    attr_reader :keyword
    attr_reader :value
    #--------------------------------------------------------------------------
    # * Object construction
    #--------------------------------------------------------------------------
    def initialize(keyword, value)
      @keyword = keyword
      @value = value
      @raw = value
    end
    #--------------------------------------------------------------------------
    # * Type coercion
    #--------------------------------------------------------------------------
    def coercion(type)
      return self unless Entity::Types.include?(type)
      @value = Entity::cast(@raw, type)
      self
    end
  end
  
  #==============================================================================
  # ** Complex
  #------------------------------------------------------------------------------
  # Representation of a Complex entity
  # model = <keyword attributesA="valueA" attributesB="valueB"/>
  #==============================================================================
  
  class Complex
    #--------------------------------------------------------------------------
    # * Public instances variables
    #--------------------------------------------------------------------------
    attr_reader :keyword
    attr_reader :attributes
    #--------------------------------------------------------------------------
    # * Object construction
    #--------------------------------------------------------------------------
    def initialize(keyword, attributes)
      @keyword = keyword
      @attributes = attributes
    end
    #--------------------------------------------------------------------------
    # * Accessor
    #--------------------------------------------------------------------------
    def [](key)
      @attributes[key]
    end
  end
  
end

#==============================================================================
# ** String
#------------------------------------------------------------------------------
#  String definition
#==============================================================================

class String
  #--------------------------------------------------------------------------
  # * Cast definition
  #--------------------------------------------------------------------------
  def to_string_list; self.scan(/[^,|^\s]+/) ;end
  def to_int_list; self.scan(/[^,|\s]+/).collect{|i|i.to_i} ;end
  def to_float_list; self.scan(/[^,|\s]+/).collect{|i|i.to_f} ;end
  def to_bool_list; self.scan(/[^,|^\s]+/).collect{|i|!!eval(i)} ;end
  #--------------------------------------------------------------------------
  # * Convert to command_liste
  #--------------------------------------------------------------------------
  def to_cmd_list
    command_list = {}
    self.split("\n").each do |line|
      parser = Entity.convert_line(line)
      command_list[parser.keyword] = parser if parser
    end
    command_list
  end
  #--------------------------------------------------------------------------
  # * Alias
  #--------------------------------------------------------------------------
  alias entities to_cmd_list
end

#==============================================================================
# ** Kernel
#------------------------------------------------------------------------------
#  Add Notes accessor
#==============================================================================

module Kernel
  #--------------------------------------------------------------------------
  # * Get Note form a static data
  #--------------------------------------------------------------------------
  def notes(data, id)
    datas = {
      :actors => $data_actors,
      :classes => $data_classes,
      :skills => $data_skills,
      :items => $data_items,
      :armors => $data_armors,
      :weapons => $data_weapons,
      :enemies => $data_enemies,
      :states => $data_states,
      :tilesets => $data_tilesets
    }
    return unless datas.has_key?(data)
    return datas[data][id].note
  end
end
