require_relative '../speck_helper'

require 'it_specs'

require 'it/environmented_proc'
It::Battery[It] << Speck.new(EnvironmentedProc) do |target|
  Speck.new EnvironmentedProc.instance_method :self do
    ->{ EnvironmentedProc.new {self} }
      .check {|eproc| eproc[] == eproc.self }
  end
  Speck.new EnvironmentedProc.instance_method :self= do
    object = Object.new
    ->{ EnvironmentedProc.new {self} .tap {|eproc| eproc.self = object } }
      .check {|eproc| eproc[] == object }
  end
  
  Speck.new EnvironmentedProc.instance_method :initialize do
    ->{ EnvironmentedProc.new {|arg| } }.check_exception ArgumentError
    
    eproc = EnvironmentedProc.new {}
    ->{ EnvironmentedProc.new {} }.check {|eproc| eproc.is_a? Proc }
  end
  
  Speck.new EnvironmentedProc.instance_method :inject do
    object = Object.new
    ->{ EnvironmentedProc.new {var} .inject(var: object) }
      .check {|eproc| eproc[] == object }
    ->{ EnvironmentedProc.new {[var1, var2, var3].join(' ')}
      .inject(var1: "This", var2: "is", var3: "awesome") }
      .check {|eproc| eproc[] == "This is awesome" }
    
    ->{ EnvironmentedProc.new {a + b + c} % {a: 1, b: 2, c: 3} }
      .check {|eproc| eproc[] == 6 }
    
    eproc = EnvironmentedProc.new {}
    ->{ eproc.inject(foo: 'bar') }.check {|rv| rv == eproc }
    
    Class.new do 
      def initialize
        ->{ EnvironmentedProc.new {self} }.check {|eproc| eproc[] == self }
        
        object = Object.new
        ->{ EnvironmentedProc.new {self} }.inject(self: object)
          .check {|eproc| eproc[] == object }
        self.methods.check {|methods| methods == Object.instance_methods }
      end
    end.new
  end
  
  Speck.new EnvironmentedProc.instance_method :call do
    object = Object.new
    
    # Ensure block executed properly
    array = Array.new
    ->{ EnvironmentedProc.new {array << object}.call }.check { array.include? object }
    
    ->{ EnvironmentedProc.new {object}.call }.check {|rv| rv == object }
  end
  
end