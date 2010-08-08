module Sequel
  module Plugins
    module BulkAttributes
      def self.apply(model, opts={}, &block)
        model.plugin(:instance_hooks)
      end

      def self.configure(model, opts={}, &block)
        model.associations.each do |association|
          association = model.association_reflection(association)
          next unless [:one_to_many].include?(association[:type])
          model.class_eval do
            define_method("#{association[:name]}=") do |list|
              instance_variable_set("@_queued_#{association[:name]}", list)
              after_save_hook do
                singular_name = association[:name].to_s.singularize
                send(association[:name]).each do |record|
                  record.destroy
                end
                instance_variable_get("@_queued_#{association[:name]}").each do |record|
                  send("add_#{singular_name}", record)
                end
              end
            end
          end
        end
      end

      module ClassMethods
      end

      module InstanceMethods       
      end

      module DatasetMethods       
      end
    end
  end
end

