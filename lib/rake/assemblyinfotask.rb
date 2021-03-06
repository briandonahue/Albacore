require 'rake/tasklib'

module Albacore
	class AssemblyInfoTask < Rake::TaskLib
		attr_accessor :name
		
		def initialize(name=:assemblyinfo)
			@name = name
			@asm = AssemblyInfo.new
			yield @asm if block_given?
			define
		end
		
		def define
			task name do
				@asm.write
				fail if @asm.failed
			end
		end
	end
end
