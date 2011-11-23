namespace :samurai_js do
  desc "Compile the Samurai.js library for distribution"
  task :compile do
    require 'sprockets'
    require 'pathname'
    require 'ostruct'

    class ::Rails
      class << self
        def env
          OpenStruct.new :'test?'=>true
        end
      end
    end
    def asset_path(asset); asset; end

    root = Pathname.new(__FILE__).dirname.parent.realpath
    env    = Sprockets::Environment.new(root) do |env|
      env.logger  = Logger.new(STDOUT)
      env.version = "test-0.1"
      env.append_path root
    end

    target = root.join('api', '0.1', 'tests', 'dist')
    rm_rf target

    assets = [
      'api/0.1/samurai.js',
    ]
    assets += Pathname.glob(root+'./api/0.1/tests/spec/**/*.js.coffee').map {|s| s.relative_path_from(root).to_s.sub(/\.js.*$/, '.js')}

    assets.each do |asset_path|
      asset = env.find_asset(asset_path)
      filename = target + asset_path
      mkdir_p filename.dirname
      asset.write_to(filename)
    end
  end

  desc "Run the jasmine test suite, output JUnit XML"
  task :test => :compile do
    rm_rf "0.1/tests/results.xml"
    system "cd 0.1/tests && jasmine-headless-webkit -j jasmine.yml --report results.xml"
  end
end

