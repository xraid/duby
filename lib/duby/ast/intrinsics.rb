module Duby::AST
  class Print < Node
    attr_accessor :println

    def initialize(parent, line_number, println, &block)
      super(parent, line_number, &block)
      @println = println
    end

    alias parameters children
    alias parameters= children=

    def infer(typer)
      if parameters.size > 0
        resolved = parameters.select {|param| typer.infer(param); param.resolved?}
        resolved! if resolved.size == parameters.size
      else
        resolved!
      end
      typer.no_type
    end
  end

  defmacro('puts') do |transformer, fcall, parent|
    Print.new(parent, fcall.position, true) do |print|
      if fcall.respond_to?(:args_node) && fcall.args_node
        fcall.args_node.child_nodes.map do |arg|
          transformer.transform(arg, print)
        end
      else
        []
      end
    end
  end

  defmacro('print') do |transformer, fcall, parent|
    Print.new(parent, fcall.position, false) do |print|
      if fcall.respond_to?(:args_node) && fcall.args_node
        fcall.args_node.child_nodes.map do |arg|
          transformer.transform(arg, print)
        end
      else
        []
      end
    end
  end

  class InlineCode
    def initialize(&block)
      @block = block
    end

    def inline(transformer, call)
      @block.call(transformer, call)
    end
  end
end