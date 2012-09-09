# Module commandes -  Ajout de la gestion des interupteurs locaux:
# ===============================================================================
# Par S4suk3 (corrigé par Grim)
# ===============================================================================
# a utiliser : 
# Récupère la valeur d'un interrupteur local
# cmd(:get_self_switch, id_map, id_event, lettre) 
# (lettre pouvant être "A","B","C","D" ou 1,2,3,4)

# Attribue la valeur d'un interrupteur local
# cmd(:set_self_switch, id_map, id_event, lettre, valeur) 
# (lettre pouvant être "A","B","C","D" ou 1,2,3,4)
# La valeur pouvant être soit true, :active, :on pour activer
# false, :off, pour désactiver :)

# Il est aussi possible d'utiliser 
# cmd(:self_switch, id_map, id_event, lettre) 
# et
# cmd(:self_switch, id_map, id_event, lettre, valeur) 
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
	# * map key
	#--------------------------------------------------------------------------
	def map_id_s(id)
		auth = ["A","B","C","D"]
		return id if auth.include?(id)
		return auth[id-1] if id.to_i.between?(1, 4)
		raise "bad selfswitch index"
	end
	private :map_id_s
	#--------------------------------------------------------------------------
	# * return a selfswitch
	#--------------------------------------------------------------------------
	def get_self_switch(map_id, event_id, id)
		key = [map_id, event_id, map_id_s(id)]
		return $game_self_switches[key]
	end
	#--------------------------------------------------------------------------
	# * assign a selfSwitch
	#--------------------------------------------------------------------------
	def set_self_switch(map_id, event_id, id, flag)
		key = [map_id, event_id, map_id_s(id)]
		value = (flag == true || flag == :active || flag == :on)
		$game_self_switches[key] = value
	end
	#--------------------------------------------------------------------------
	# * c API
	#--------------------------------------------------------------------------
	def self_switch(*args)
		return get_self_switch(*args) if args.length == 3
		set_self_switch(*args)
	end
end