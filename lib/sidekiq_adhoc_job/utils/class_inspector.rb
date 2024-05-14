require 'method_source'

module SidekiqAdhocJob
  module Utils
    class ClassInspector

      attr_reader :klass_name, :klass_obj, :method_parameters

      def initialize(klass_name)
        @klass_name = klass_name
        @klass_obj = klass_name.new
        @method_parameters = {}
      end

      def parameters(method_name)
        return method_parameters[method_name] if method_parameters[method_name]

        method_object = klass_obj.method(method_name)
        klass_method = klass_method(method_object)
        # Get the source code of the method
        source = method_object.source
        params = klass_method
                 .parameters
                 .group_by { |type, _| type }
                 .inject({}) do |acc, (type, params)|
                   if type == :opt
                     acc[type] = params.map do |param|
                       default_value = eval(source[/#{param.last} ?= ?(.+?)(,|\))/, 1])
                        { key: param.last, default: default_value }
                     end
                   else
                     acc[type] = params.map { |param| { key: param.last, default: nil } }
                   end
                   acc
                 end

        method_parameters[method_name] = params

        params
      end

      def required_parameters(method_name)
        parameters(method_name)[:req] || []
      end

      def optional_parameters(method_name)
        parameters(method_name)[:opt] || []
      end

      def required_kw_parameters(method_name)
        parameters(method_name)[:keyreq] || []
      end

      def optional_kw_parameters(method_name)
        parameters(method_name)[:key] || []
      end

      def has_rest_parameter?(method_name)
        !!parameters(method_name)[:rest]
      end

      def klass_method(method)
        return method if method.owner == klass_name

        klass_method(method.super_method)
      end

    end
  end
end
