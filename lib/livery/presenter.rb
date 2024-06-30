module Livery
  class Presenter
    attr_reader :resource

    def initialize(resource, options = {})
      @resource = resource
      options.each do |k, v|
        raise ArgumentError, "cannot initialize `resource` variable" if k.to_s == "resource"
        instance_variable_set("@#{k}", v)
      end
    end

    class << self
      def formatted_datetime(*names)
        names.each do |name|
          define_method name do
            value = @resource.public_send(name)
            I18n.l(value)
          end
        end
      end

      def method_added(sym)
        raise "can't override resource on a subclass of Presenter" if sym == :resource
      end

      def presenter_association(*names, source: nil, namespace: nil)
        raise ArgumentError, '`source` must be a block' unless source.nil? || source.is_a?(Proc)

        names.each do |name|
          instance_variable_name = "@#{name}".to_sym

          define_method name do
            return instance_variable_get(instance_variable_name) if instance_variable_defined?(instance_variable_name)

            association_resource = source.nil? ? @resource.public_send(name) : @resource.instance_exec(&source)

            association_presenter = Presenter.to_presenter(association_resource, namespace: namespace)

            instance_variable_set(instance_variable_name, association_presenter)
            association_presenter
          end
        end
      end

      def presenterize(klass, namespace: nil)
        presenter_klass_string = [namespace, "#{klass}Presenter"].compact.join('::')
        ActiveSupport::Inflector.constantize(presenter_klass_string)
      end

      def resource(sym)
        define_method sym do
          @resource
        end
      end

      def to_presenter(object, namespace: nil)
        return object.map { |o| to_presenter_single(o, namespace: namespace) } if object.is_a?(Enumerable)
        to_presenter_single(object, namespace: namespace)
      end

      private

      def to_presenter_single(object, namespace: nil)
        return nil if object.nil?

        klass = object.class

        if klass < Presenter
          object
        else
          presenterize(klass, namespace: namespace).new(object)
        end
      end
    end

    def t(*args)
      I18n.t(resolve_i18n_path(args.shift), *args)
    end

    def t!(*args)
      I18n.t!(resolve_i18n_path(args.shift), *args)
    end

    def to_model
      raise 'Presenter objects should not be used for forms. Call .resource on this Presenter'
    end

    def to_param(*args)
      @resource.to_param(*args)
    end

    private

    def resolve_i18n_path(key)
      if key[0] != '.'
        key
      else
        ActiveSupport::Inflector.underscore(self.class.name).tr('/', '.') + key
      end
    end
  end
end
