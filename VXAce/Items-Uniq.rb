#==============================================================================
# ** Uniq Item
#------------------------------------------------------------------------------
#  Les objets ont chacun leur identité propre (instance de Game_Item, Game_Armor
#  et Game_Weapon )
#  Il est possible de travailler sur chacun d'eux individuellement.

# Idée originale : Avygeil
# Par Nuki (http://www.biloucorp.com)
# Funkywork - Biloucorp
# Credits : rien 
# Merci à Hiino et Zangther
#==============================================================================

#==============================================================================
# ** BaseItem
#------------------------------------------------------------------------------
#  Description of a simple Item
#==============================================================================

module BaseItem
	#--------------------------------------------------------------------------
	# * Setup a Baseitem
	#--------------------------------------------------------------------------
	def setup_base(id, list)
		@id = list[id].id
		@name = list[id].name
		@icon_index = list[id].icon_index
		@description = list[id].description
		@features = list[id].features
		@note = list[id].note
	end
end

#==============================================================================
# ** EquipItem
#------------------------------------------------------------------------------
#  Description of an Equipable item
#==============================================================================

module EquipItem
	#--------------------------------------------------------------------------
	# * Mixins
	#--------------------------------------------------------------------------
	include BaseItem
	#--------------------------------------------------------------------------
 	# * Setup an EquipItem
  	#--------------------------------------------------------------------------
	def setup_equip(id, list)
		setup_base(id, list)
		@price = list[id].price
		@etype_id = list[id].etype_id
		@params = list[id].params
	end
end

#==============================================================================
# ** UsableItem
#------------------------------------------------------------------------------
#  Description of an Usable item
#==============================================================================

module UsableItem
	#--------------------------------------------------------------------------
	# * Mixins
	#--------------------------------------------------------------------------
	include BaseItem
	#--------------------------------------------------------------------------
	# * Setup an UsableItem
	#--------------------------------------------------------------------------
	def setup_usable(id, list)
		setup_base(id, list)
		@scope = list[id].scope
		@occasion = list[id].occasion
		@speed = list[id].speed
		@success_rate = list[id].success_rate
		@repeats = list[id].repeats
		@tp_gain = list[id].tp_gain
		@hit_type = list[id].hit_type
		@animation_id = list[id].animation_id
		@damage = list[id].damage
		@effects = list[id].effects
	end
end

#==============================================================================
# ** Game_Item
#------------------------------------------------------------------------------
#  Description of an item
#==============================================================================

class Game_Item < RPG::Item
	#--------------------------------------------------------------------------
	# * Mixins
	#--------------------------------------------------------------------------
	include UsableItem
	#--------------------------------------------------------------------------
  	# * Object initialisation
  	#--------------------------------------------------------------------------
	def initialize(id)
		super()
		setup_usable(id, $data_items)
		@scope = $data_items[id].scope
		@itype_id = $data_items[id].itype_id
		@price = $data_items[id].price
		@consumable = $data_items[id].consumable
	end
end

#==============================================================================
# ** Game_Weapon
#------------------------------------------------------------------------------
#  Description of a weapon
#==============================================================================

class Game_Weapon < RPG::Weapon
	#--------------------------------------------------------------------------
	# * Mixins
	#--------------------------------------------------------------------------
	include EquipItem
	#--------------------------------------------------------------------------
  	# * Object initialisation
  	#--------------------------------------------------------------------------
	def initialize(id)
		super()
		setup_equip(id, $data_weapons)
		@wtype_id = $data_weapons[id].wtype_id
		@animation_id = $data_weapons[id].animation_id
	end
end

#==============================================================================
# ** Game_Armor
#------------------------------------------------------------------------------
#  Description of an armor
#==============================================================================

class Game_Armor < RPG::Armor
	#--------------------------------------------------------------------------
	# * Mixins
	#--------------------------------------------------------------------------
	include EquipItem
	#--------------------------------------------------------------------------
  	# * Object initialisation
  	#--------------------------------------------------------------------------
	def initialize(id)
		super()
		setup_equip(id, $data_armors)
		@atype_id = $data_armors[id].atype_id
		@etype_id = $data_armors[id].etype_id
	end
end

#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  This class handles parties. Information such as gold and items is included.
# Instances of this class are referenced by $game_party.
#==============================================================================

class Game_Party
	#--------------------------------------------------------------------------
	# * Initialize All Item Lists
	#--------------------------------------------------------------------------
	def init_all_items
		@items = []
		@weapons = []
		@armors = []
	end
	#--------------------------------------------------------------------------
	# * build item
	#--------------------------------------------------------------------------
	def build_item(item)
		return Game_Item.new(item.id) if item.is_a?(RPG::UsableItem)
		return Game_Weapon.new(item.id) if item.is_a?(RPG::Weapon)
		return Game_Armor.new(item.id) if item.is_a?(RPG::Armor)
		return nil
	end
	#--------------------------------------------------------------------------
	# * Get Item Object Array 
	#--------------------------------------------------------------------------
	def items
		@items.sort{|item1, item2|item1.id<=>item2.id}.uniq do |item|
			item.id
		end
	end
	#--------------------------------------------------------------------------
	# * Get Weapon Object Array 
	#--------------------------------------------------------------------------
	def weapons
		@weapons.sort{|item1, item2|item1.id<=>item2.id}.uniq do |item|
			item.id
		end
	end
	#--------------------------------------------------------------------------
	# * Get Armor Object Array 
	#--------------------------------------------------------------------------
	def armors
		@armors.sort{|item1, item2|item1.id<=>item2.id}.uniq do |item|
			item.id
		end
	end
	#--------------------------------------------------------------------------
	# * Get Container Object Corresponding to Item Class
	#--------------------------------------------------------------------------
	def item_container(item_class)
		return @items   if item_class == RPG::Item || item_class == Game_Item
		return @weapons if item_class == RPG::Weapon || item_class == Game_Weapon
		return @armors  if item_class == RPG::Armor || item_class == Game_Armor
		return nil
	end
	#--------------------------------------------------------------------------
	# * Get Number of Items Possessed
	#--------------------------------------------------------------------------
	def item_number(item)
		container = item_container(item.class)
		container ? container.count{|elt|elt.id == item.id} || 0 : 0
	end
	#--------------------------------------------------------------------------
	# * Determine if Specified Item Is Included in Members' Equipment
	#--------------------------------------------------------------------------
	def members_equip_include?(item)
		members.any? {|actor| actor.equips.find{|elt| elt.id == item.id} != nil }
	end
	#--------------------------------------------------------------------------
	# * Increase/Decrease Items
	#     include_equip : Include equipped items
	#--------------------------------------------------------------------------
	def gain_item(item, amount, include_equip = false)
		container = item_container(item.class)
		return unless container
		item = build_item(item)
		return unless item
		if amount > 0
			amount.times do 
				container << build_item(item) if item_number(item) < 99
			end
		else
			amount.abs.times do 
				if item_number(item) > 0
					item_finded = container.find{|elt|elt.id == item.id}
					container.delete(item_finded)
				end
			end
		end
	end
end
