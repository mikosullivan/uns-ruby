require 'uri'

#==============================================================================
# UNS
#
class UNS
	attr_reader :uri
	
	
	#--------------------------------------------------------------------------
	# initialize
	#
	def initialize(raw)
		@uri = nil
		
		if raw.is_a?(URI)
			if not raw.is_a?(URI::HTTPS)
				raise 'input-not-https: ' + raw.to_s
			end
			
			@uri = raw.clone
		else
			raw = raw.to_s
			raw = raw.gsub('~', '/')
			
			if not raw.match(/\Ahttps?\:\/\//mi)
				raw = 'https://' + raw
			end
			
			@uri = URI(raw)
		end
	end
	#
	# initialize
	#--------------------------------------------------------------------------
	
	
	#--------------------------------------------------------------------------
	# conversion methods
	#
	def concise
		return @uri.host + @uri.path
	end
	
	alias_method :to_s, :concise
	
	def file_name
		return (@uri.host + @uri.path).gsub(/\//mu, '~')
	end
	#
	# conversion methods
	#--------------------------------------------------------------------------
end
#
# UNS
#==============================================================================


#==============================================================================
# UNS class methods
#
class << UNS
	HOLD = {}
	
	#--------------------------------------------------------------------------
	# conversion methods
	#
	def uri(raw)
		return self.new(raw).uri
	end
	
	def concise(raw)
		return self.new(raw).concise
	end
	
	alias_method :to_s, :concise
	
	def file_name(raw)
		return self.new(raw).file_name
	end
	#
	# conversion methods
	#--------------------------------------------------------------------------
	
	
	#--------------------------------------------------------------------------
	# []
	#
	def [](raw)
		file_name = UNS.file_name(raw) + '.rb'
		file_name = file_name.gsub('.', '\\.')
		
		# See https://stackoverflow.com/questions/357754/can-i-traverse-symlinked-directories-in-ruby-with-a-glob
		# for where I got this crazy glob pattern.
		glob = '**{,/*/**}/' + file_name
		
		# loop through load path
		$LOAD_PATH.each do |dir|
			Dir.glob(dir + '/' + glob).each do |path|
				::Kernel.load(path)
				return HOLD.delete('loaded')
			end
		end
	end
	#
	# []
	#--------------------------------------------------------------------------
	
	
	#--------------------------------------------------------------------------
	# load
	#
	def load()
		ctrl = UNS::Ctrl.new()
		yield ctrl
		HOLD['loaded'] = ctrl.return
	end
	#
	# load
	#--------------------------------------------------------------------------
end
#
# UNS class methods
#==============================================================================


#==============================================================================
# UNS::Ctrl
#
class UNS::Ctrl
	attr_accessor :return
	
	def initialize
		@return = nil
	end
end
#
# UNS::Ctrl
#==============================================================================