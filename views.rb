puts "Using HAML by default..."
gem 'haml'
gem 'haml-rails'

inject_into_file "config/application.rb", :after => "config.generators do |generator|\n" do
  (" " * 6) + "generator.template_engine :haml\n"
end

create_file "config/initializers/haml.rb" do
  <<-HAML
  Haml::Template.options[:attr_wrapper] = '\"'
  Haml::Template.options[:format] = :xhtml
  Sass::Plugin.options[:style] = :expanded
  HAML
end

run "bundle install --quiet"
git :add => ".", :commit => "-m 'Use HAML'"

puts "Using jQuery..."
gem "jquery-rails"
run "bundle install --quiet"
generate "jquery:install", "--ui"
git :add => ".", :rm => "public/javascripts/controls.js public/javascripts/dragdrop.js public/javascripts/effects.js public/javascripts/prototype.js", :commit => "-m 'Use jQuery'"

puts "Using simple navigation..."
gem "simple-navigation"
run "bundle install --quiet"
generate "navigation_config"
git :add => ".", :commit => "-m 'Use simple_navigation'"

puts "Using Kaminari for pagination..."
gem "kaminari"
run "bundle install --quiet"
git :add => ".", :commit => "-m 'Use Kaminari'"

puts "Using simple_form..."
gem "simple_form"
run "bundle install --quiet"
generate "simple_form:install"
git :add => ".", :commit => "-m 'Use simple_form'"

if y?("Generate nifty layout?")
  generate "nifty:layout", "-f", "--haml"
  git :add => ".", :commit => "-m 'Add nifty layout'"
end

if y?("Generate web-app-theme layout?")
  gem "web-app-theme", :git => "https://github.com/stevehodgkiss/web-app-theme.git", :group => :development
  run "bundle install --quiet"

  options = []

  theme = ask "Which theme would you like to use? (none for default) "
  options << "--theme=#{theme}" unless theme == ''

  app_name = ask "What is the name of the application?"
  options << "--app-name='#{app_name}'" unless app_name == ''

  options << "--engine=haml"

  generate "web_app_theme:theme", options.flatten

  git :add => ".", :commit => "-m 'Add web-app-theme layout'"

  puts "You might need to tidy up web-app-theme a lot if you use other template functionality."
end

if y?("Use Cappuccino?")
  if y?("Use a CIB based app?")
    arguments = "-t NibApplication"
  else
    arguments = "-t Application"
  end

  appName = ask "What's the name of the app?"

  run "capp gen #{appName} #{arguments}"
  run "mv #{appName} Cappuccino"

  run "echo 'Cappuccino/Build/*' >> .gitignore"

  git :add => ".", :commit => "-m 'Added Cappuccino'"
end

puts "Adding a simple static home page..."
run "curl -s -L #{@templates_path}/resources/static/static_controller.rb > app/controllers/static_controller.rb"
run "mkdir app/views/static"
run "curl -s -L #{@templates_path}/resources/static/home.html.erb > app/views/static/home.html.erb"

route "root :to => 'static#home'"

git :add => ".", :commit => "-m 'Static home page'"
