# Module to get the RTP directory Path
# By Grim - 
# http://biloucorp.com http://biloucorp.com/BCW/Grim - http://funkywork.blogspot.com
# Credits : Nothing :D
# Special Thanks to Skillo
#==============================================================================
# ** RTP
#------------------------------------------------------------------------------
#  Get information about RTP
#==============================================================================
module RTP
	#--------------------------------------------------------------------------
  	# * Class variable
  	#--------------------------------------------------------------------------
	@@rtp_directory = nil
	#--------------------------------------------------------------------------
  	# * WIN32API
  	#--------------------------------------------------------------------------
	RegOpenKeyExA = Win32API.new('advapi32.dll', 'RegOpenKeyExA', 'LPLLP', 'L')
	RegQueryValueExA = Win32API.new('advapi32.dll', 'RegQueryValueExA', 'LPLPPP', 'L')
	RegCloseKey = Win32API.new('advapi32', 'RegCloseKey', 'L', 'L')
	#--------------------------------------------------------------------------
  	# * Singleton of RTP
  	#--------------------------------------------------------------------------
	extend self
	#--------------------------------------------------------------------------
  	# * Return the PATH of the RTP directory
  	#--------------------------------------------------------------------------
	def path
		unless @@rtp_directory
			read_ini = lambda{|val|File.foreach("Game.ini"){|line| break($1) if line =~ /^#{val}=(.*)$/}}
			key = type = size = [].pack("x4")
			RegOpenKeyExA.(2147483650, 'Software\Enterbrain\RGSS3\RTP', 0, 131097, key)
			key = key.unpack('l').first
			rtp_data = read_ini.("RTP")
			RegQueryValueExA.(key, rtp_data, 0, type, 0, size)
			buffer = ' '*size.unpack('l').first
			RegQueryValueExA.(key, rtp_data, 0, type, buffer, size)
			RegCloseKey.(key)
			@@rtp_directory = (buffer.gsub(/\\/, '/')).delete!(0.chr)
			@@rtp_directory += "/" if @@rtp_directory[-1] != "/"
		end
		return @@rtp_directory
	end
end