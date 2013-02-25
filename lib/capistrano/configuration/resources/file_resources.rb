require "capistrano/configuration/resources/file_resources/version"
require "capistrano/configuration"
require "erb"

module Capistrano
  class Configuration
    module Resources
      module FileResources
        def file(name, options={})
          path = options.fetch(:path, ".")
          begin
            File.read(File.join(path, name))
          rescue SystemCallError => error
            abort("Could not render file resource - #{error}")
          end
        end

        def template(name, options={})
          path = options.fetch(:path, ".")
          name = "#{name}.erb" if File.exist?(File.join(path, "#{name}.erb"))
          data = file(name, options)
          begin
            ERB.new(data).result(binding)
          rescue StandardError => error
            abort("Could not render template resource - #{error}")
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Configuration.instance.extend(Capistrano::Configuration::Resources::FileResources)
end

# vim:set ft=ruby sw=2 ts=2 :
