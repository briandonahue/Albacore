require File.join(File.dirname(__FILE__), 'support', 'spec_helper')
require 'albacore/zipdirectory'
require 'rake/ziptask'
require 'tasklib_patch'

describe Albacore::ZipTask, "when running" do
	before :all do
		Albacore::ZipTask.new() do |t|
			@yielded_object = t
		end
	end
	
	it "should yield the zip api" do
		@yielded_object.kind_of?(ZipDirectory).should be_true
	end
end

describe Albacore::ZipTask, "when execution fails" do
	before :all do
		@task = Albacore::ZipTask.new(:failingtask)
		@task.extend(TasklibPatch)
		Rake::Task["failingtask"].invoke
		@task.fail
	end
	
	it "should fail the rake task" do
		$task_failed.should == true
	end
end
