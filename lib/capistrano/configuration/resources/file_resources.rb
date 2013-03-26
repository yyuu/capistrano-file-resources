require "capistrano/configuration/resources/file_resources/version"
require "capistrano/configuration"
require "erb"
require "mime/types"

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
          if File.exist?(File.join(path, "#{name}.erb"))
            name = "#{name}.erb"
          else
            types = MIME::Types.type_for(name)
            if types.include?("text/html")
              name_without_ext = File.basename(name, File.extname(name))
              if File.exist?(File.join(path, "#{name_without_ext}.rhtml"))
                name = "#{name_without_ext}.rhtml"
              end
            end
          end
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
