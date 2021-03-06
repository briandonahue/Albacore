task :default => ['albacore:sample']

namespace :specs do
	require 'spec/rake/spectask'

	@spec_opts = '--colour --format specdoc'

	desc "Run functional specs for Albacore"
	Spec::Rake::SpecTask.new :all do |t|
		t.spec_files = 'spec/**/*_spec.rb'
		t.spec_opts << @spec_opts
	end
	
	desc "Assembly info functional specs"
	Spec::Rake::SpecTask.new :assemblyinfo do |t|
		t.spec_files = 'spec/assemblyinfo*_spec.rb'
		t.spec_opts << @spec_opts
	end
	
	desc "MSBuild functional specs"
	Spec::Rake::SpecTask.new :msbuild do |t|
		t.spec_files = 'spec/msbuild*_spec.rb'
		t.spec_opts << @spec_opts
	end

	desc "SQLServer SQLCmd functional specs" 
	Spec::Rake::SpecTask.new :sqlcmd do |t|
		t.spec_files = 'spec/sqlcmd*_spec.rb'
		t.spec_opts << @spec_opts
	end
	
	desc "NCover Console functional specs"
	Spec::Rake::SpecTask.new :ncoverconsole do |t|
		t.spec_files = 'spec/ncoverconsole*_spec.rb'
		t.spec_opts << @spec_opts
	end	
	
	desc "NCover Report functional specs"
	Spec::Rake::SpecTask.new :ncoverreport do |t|
		t.spec_files = 'spec/ncoverreport*_spec.rb'
		t.spec_opts << @spec_opts
	end

	desc "SSH functional specs"
	Spec::Rake::SpecTask.new :ssh do |t|
		t.spec_files = 'spec/ssh*_spec.rb'
		t.spec_opts << @spec_opts
	end	

	desc "Expand Templates functional specs"
	Spec::Rake::SpecTask.new :ssh do |t|
		t.spec_files = 'spec/expandtemplates*_spec.rb'
		t.spec_opts << @spec_opts
	end	
end

namespace :albacore do	
	require 'lib/albacore'

	desc "Run a complete Albacore build sample"
	task :sample => ['albacore:assemblyinfo', 'albacore:msbuild', 'albacore:ncoverconsole', 'albacore:ncoverreport']
	
	desc "Run a sample build using the MSBuildTask"
	Albacore::MSBuildTask.new(:msbuild) do |msb|
		msb.properties = {:configuration => :Debug}
		msb.targets [:Clean, :Build]
		msb.solution = "spec/support/TestSolution/TestSolution.sln"
	end
	
	desc "Run a sample assembly info generator"
	Albacore::AssemblyInfoTask.new(:assemblyinfo) do |asm|
		asm.version = "0.1.2.3"
		asm.company_name = "a test company"
		asm.product_name = "a product name goes here"
		asm.title = "my assembly title"
		asm.description = "this is the assembly description"
		asm.copyright = "copyright some year, by some legal entity"
		asm.custom_attributes :SomeAttribute => "some value goes here", :AnotherAttribute => "with some data"
		
		asm.output_file = "spec/support/AssemblyInfo/AssemblyInfo.cs"
	end
	
	desc "Run a sample NCover Console code coverage"
	Albacore::NCoverConsoleTask.new(:ncoverconsole) do |ncc|
		@xml_coverage = "spec/support/CodeCoverage/test-coverage.xml"
		File.delete(@xml_coverage) if File.exist?(@xml_coverage)
		
		ncc.log_level = :verbose
		ncc.path_to_command = "spec/support/Tools/NCover-v3.3/NCover.Console.exe"
		ncc.output = {:xml => @xml_coverage}
		ncc.working_directory = "spec/support/CodeCoverage/nunit"
		
		nunit = NUnitTestRunner.new("spec/support/Tools/NUnit-v2.5/nunit-console.exe")
		nunit.log_level = :verbose
		nunit.assemblies << "assemblies/TestSolution.Tests.dll"
		nunit.options << '/noshadow'
		
		ncc.testrunner = nunit
	end	
	
	desc "Run a sample NCover Report to check code coverage"
	Albacore::NCoverReportTask.new(:ncoverreport => :ncoverconsole) do |ncr|
		@xml_coverage = "spec/support/CodeCoverage/test-coverage.xml"
		
		ncr.path_to_command = "spec/support/Tools/NCover-v3.3/NCover.Reporting.exe"
		ncr.coverage_files << @xml_coverage
		
		fullcoveragereport = NCover::FullCoverageReport.new
		fullcoveragereport.output_path = "spec/support/CodeCoverage/report/output"
		ncr.reports << fullcoveragereport
		
		ncr.required_coverage << NCover::BranchCoverage.new(:minimum => 10)
		ncr.required_coverage << NCover::CyclomaticComplexity.new(:maximum => 1)
	end
end

namespace :jeweler do
	require 'jeweler'	
	Jeweler::Tasks.new do |gs|
		gs.name = "Albacore"
		gs.summary = "A Suite of Rake Build Tasks For .Net Solutions"
		gs.description = "Easily build your .NET solutions with rake, using this suite of custom tasks."
		gs.email = "derickbailey@gmail.com"
		gs.homepage = "http://github.com/derickbailey/Albacore"
		gs.authors = ["Derick Bailey", "Ben Hall"]
		gs.has_rdoc = false	
		gs.files.exclude("Albacore.gemspec", ".gitignore", "spec/support/Tools")

		gs.add_dependency('rake', '>= 0.8.7')
		gs.add_dependency('net-ssh', '>= 2.0.15')
		gs.add_dependency('net-sftp', '>= 2.0.2')
		gs.add_dependency('rubyzip', '>= 0.9.1')

		gs.add_development_dependency('rspec', '>= 1.2.8')
		gs.add_development_dependency('jeweler', '>= 1.2.1')
		gs.add_development_dependency('derickbailey-notamock', '>= 0.0.1')
	end
end
