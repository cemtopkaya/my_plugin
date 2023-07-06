# encoding: utf-8

require "redmine"
begin
  require "config/initializers/session_store.rb"
rescue LoadError
  puts ">>> init.rb içinde store.rb yüklenirken hata"
end

def init
  Dir::foreach(File.join(File.dirname(__FILE__), "lib")) do |file|
    next unless /\.rb$/ =~ file
    require_dependency file
  end
end

if Rails::VERSION::MAJOR >= 5
  ActiveSupport::Reloader.to_prepare do
    init
  end
elsif Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    init
  end
else
  Dispatcher.to_prepare :redmine_closed_date do
    init
  end
end

Redmine::Plugin.register :my_plugin do
  name "My Plugin"
  author "Your Name"
  description "A simple Redmine plugin that adds custom content to the issue details page."
  version "1.0.0"
  url "https://example.com/plugin_homepage"
  author_url "https://example.com/your_website"
  requires_redmine :version_or_higher => "4.0.0"

  PLUGIN_ROOT = Pathname.new(__FILE__).join("..").realpath.to_s
  options = YAML::load(File.open(File.join(PLUGIN_ROOT + "/config", "settings.yml")))

  settings default: {
    "rest_api_url" => options["rest_api_url"],
    "rest_api_username" => options["rest_api_username"],
    "rest_api_password" => options["rest_api_password"],
  }, partial: "settings/my_plugin_settings"
end
