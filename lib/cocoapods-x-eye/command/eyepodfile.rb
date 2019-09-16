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
      class EyePodfile < Command
        include RepoUpdate
        self.summary = '展示SDK依赖轨迹'
  
        self.description = <<-DESC
          展示SDK依赖轨迹，如果SDK的依赖项没有指定依赖版本，默认查找最新。
        DESC
  
        self.arguments = [
        ]
  
        def self.options
          options = [
            # ["--sources=https://github.com/artsy/Specs,master", "指定搜索源"],
            ['--repo-update', '在eye之前强制执行 pod repo update'],
          ]
        end
  
        def initialize(argv)
          @name = argv.shift_argument
          @version = argv.shift_argument
          @repo_update = argv.flag?('repo-update')
          super
        end
  
        def validate!
          super
        end
  
        def run
            verify_podfile_exists!
        end
  
        
      end
    end
  end