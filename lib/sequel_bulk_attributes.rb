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
              cur = send(association[:name])
              instance_variable_set("@_#{association[:name]}_add", list.reject{ |v| cur.detect{ |v1| v.pk == v1.pk } })
              instance_variable_set("@_#{association[:name]}_remove", cur.reject{ |v| list.detect{ |v1| v.pk == v1.pk } })
              cur.replace(list)

              after_save_hook do
                singular_name = association[:name].to_s.singularize

                instance_variable_get("@_#{association[:name]}_remove").each do |record|
                  send("remove_#{singular_name}", record)
                end

                instance_variable_get("@_#{association[:name]}_add").each do |record|
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

