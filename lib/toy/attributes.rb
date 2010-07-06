# encoding: UTF-8
module Toy
  module Attributes
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods

    included do
      class_inheritable_hash :model_attributes
    end

    module ClassMethods
      def define_attribute_methods
        attribute_method_suffix "", "=", "?"
        super(model_attributes.keys)
      end

      def attribute(key)
        key = key.to_sym
        write_inheritable_hash :model_attributes, {key => Attribute.new(self, key)}
      end

      def attribute?(key)
        model_attributes.keys.include?(key.to_sym)
      end
    end

    module InstanceMethods
      def initialize(attrs={})
        return if attrs.nil?
        attrs.each do |key, value|
          write_attribute(key, value)
        end
      end

      def attributes
        @attributes ||= {}.with_indifferent_access
      end

      def respond_to?(*args)
        self.class.define_attribute_methods
        super
      end

      def method_missing(method, *args, &block)
        if !self.class.attribute_methods_generated?
          self.class.define_attribute_methods
          send(method, *args, &block)
        else
          super
        end
      end

      protected
        def write_attribute(key, value)
          attributes[key] = value
        end

        def read_attribute(key)
          attributes[key]
        end

        def attribute_method?(key)
          self.class.attribute?(key)
        end

        def attribute(key)
          read_attribute(key)
        end

        def attribute=(key, value)
          write_attribute(key, value)
        end

        def attribute?(key)
          read_attribute(key).present?
        end
    end
  end
end