module Pod
  class Command
    # This is an example of a cocoapods plugin adding a top-level subcommand
    # to the 'pod' command.
    #
    # You can also create subcommands of existing or new commands. Say you
    # wanted to add a subcommand to `list` to show newly deprecated pods,
    # (e.g. `pod list deprecated`), there are a few things that would need
    # to change.
    #
    # - move this file to `lib/pod/command/list/deprecated.rb` and update
    #   the class to exist in the the Pod::Command::List namespace
    # - change this class to extend from `List` instead of `Command`. This
    #   tells the plugin system that it is a subcommand of `list`.
    # - edit `lib/cocoapods_plugins.rb` to require this file
    #
    # @todo Create a PR to add your plugin to CocoaPods/cocoapods.org
    #       in the `plugins.json` file, once your plugin is released.
    #
    class Eye < Command
      class Single < Eye
        include RepoUpdate
        self.summary = '展示SDK依赖轨迹'

        self.description = <<-DESC
          展示SDK依赖轨迹，如果SDK的依赖项没有指定依赖版本，默认查找最新。
        DESC

        self.arguments = [
          CLAide::Argument.new('NAME', true),
          CLAide::Argument.new('VERSION', false),
        ]

        def self.options
          options = [
            ["--sources=https://github.com/artsy/Specs,master", "指定搜索源"],
            ['--repo-update', '在eye之前强制执行 pod repo update'],
          ]
        end

        def initialize(argv)
          @name = argv.shift_argument
          @version = argv.shift_argument
          @source_urls = argv.option('sources', config.sources_manager.all.map(&:url).join(',')).split(',')
          @repo_update = argv.flag?('repo-update')
          super
        end

        def validate!
          super
          help! '请提供一个Pod名称' unless @name
          help! '请提供一个Pod版本' unless @version
        end

        def run
          UI.puts "Begin Searching #{@name}, #{@version}"
          spec = spec_with_name(@name, @version)
          if spec == nil 
            puts "Error:找不到name=#{@name}&version=#{@version}的pod"
          end
          puts spec
          puts recuse_spec_dependencies(spec, {}).to_json
        end

        def recuse_spec_dependencies(spec, locus)
          if locus == nil 
            locus = {}
          end
          depen_specs = []
          for dependency in spec.dependencies 
            dep_spec = spec_with_dep(dependency)
            if dep_spec == nil 
              puts "Error to find #{dependency}"
            else
              depen_specs<<recuse_spec_dependencies(dep_spec, {})
            end
          end
          locus[:dep] = depen_specs
          
          sub_specs = {}
          for sub_spec in spec.subspecs
            sub_spec_array = []
            for sub_dep in sub_spec.dependencies
                sub_dep_spec = spec_with_dep(sub_dep)
                if sub_dep_spec == nil 
                  puts "Error to find #{sub_dep}"
                else
                  if sub_dep_spec.name != spec.name
                    sub_spec_array<<recuse_spec_dependencies(sub_dep_spec, {})
                  end
                end
            end
            name = sub_spec.name
            sub_specs[name] = sub_spec_array
          end
          locus[:sub_specs] = sub_specs
          locus[:name] = spec.name
          return locus
        end

        def spec_with_dep(dependency)
          return nil if dependency.nil?

          set = Pod::Config.instance.sources_manager.search(dependency)
          
          return set.specification
        end

        def spec_with_name(name, version)
          return if name.nil?

          set = Pod::Config.instance.sources_manager.search(Dependency.new(name))
          return nil if set.nil?
          if version != nil 
            paths = set.sources.map { |source| source.specification_path(name, version) }
            if paths.count == 0
              return nil
            end
            Specification.from_file(paths.first) 
          else
            set.specification
          end
        end

        def sources_manager
          defined?(Pod::SourcesManager) ? Pod::SourcesManager : config.sources_manager
        end
      end
    end
  end
end