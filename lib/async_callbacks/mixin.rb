module AsyncCallbacks::Mixin
  extend ActiveSupport::Concern

  METHOD_REGEX  = Regexp.new(/^async_callback_(.+)$/)
  SERIALIZER    = YAML
  MONGOID_ATTRS = [:@new_record, :@attributes, :@changed_attributes]

  def method_missing(method, *args)
    if method.to_s =~ AsyncCallbacks::METHOD_REGEX
      vars = instance_variables
      unless self.class.ancestors.include?(Promiscuous::Subscriber::Model::Observer)
        vars = vars.select { |v| MONGOID_ATTRS.include?(v) }
      end

      vars_hash = {}
      vars.each { |i| vars_hash[i] = self.instance_variable_get(i) }
      vars_hash = SERIALIZER.dump(vars_hash)

      AsyncCallbacks::Worker.perform_async(vars_hash, $1, finder)
      AsyncCallbacks::Worker.drain if AsyncCallbacks::Worker.auto_drain
    else
      super
    end
  end

  private

  def finder
    if self.is_a?(Promiscuous::Subscriber::Model::Observer)
      "#{self.class}.new"
    elsif self.is_a?(Mongoid::Document)
      instance = self
      finder = []
      while instance.embedded?
        if instance.metadata.relation == Mongoid::Relations::Embedded::One
          finder << "#{instance.metadata.name}"
        else
          finder << "#{instance.metadata.name}.find('#{instance.id}')"
        end
        instance = instance._parent
      end
      finder << "#{instance.class}.find('#{instance.id}')"
      finder.reverse.join('.')
    end
  end
end

class ActiveSupport::Callbacks::Callback
  alias_method :initialize_without_async_callback, :initialize
  def initialize(chain, filter, kind, options, klass)
    initialize_without_async_callback(chain, filter, kind, options, klass)
    if klass.ancestors.include?(AsyncCallbacks) && kind == :after
      @filter = "async_callback_#{self.filter}".to_sym
    end
  end
end
