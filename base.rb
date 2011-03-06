def y?(s)
  yes? "\n#{s} (y/n)", :yellow
end

def maybe_update_file(options = {})
  old_contents = File.read options[:file]
  look_for = options[:after] || options[:before] # but not both!
  return if options[:unless_present] && old_contents =~ options[:unless_present]

  if options[:action].nil? || y?("Should I #{options[:action]} to #{options[:file]}?")
    File.open(options[:file], "w") do |file|
      file.print old_contents.sub(look_for, "#{look_for}\n#{options[:content]}") if options[:after]
      file.print old_contents.sub(look_for, "#{options[:content]}\n#{look_for}") if options[:before]
    end

    if old_contents.scan(look_for).length > 1
      puts "\nNOTE: #{options[:file]} may not have been updated correctly, so please take a look at it.\n"
    end
  end
end

def bundle
  puts "Running bundle install..."
  run "bundle install --quiet"
end

@templates_path = "https://github.com/benlangfeld/rails-templates/raw/master"

@nifty_layout = y? "Generate nifty layout?"
@web_app_theme = y? "Generate web-app-theme layout?"
@web_app_theme_theme = ask("Which theme would you like to use? (none for default) ") if @web_app_theme
@mocha = y? "Install mocha?"
@cream = y? "Use Cream (Devise, CanCan & Roles Generic) for authentication and authorization?"
if @cream
  @cream_strategy = ask "What role strategy should we use? (default is admin_flag)"
  @cream_roles = ask "What roles should we use (separate by spaces)? (defaults :guest and :admin)"
end
@cappuccino = y? "Use Cappuccino?"
@cib_app = y?("Use a CIB based app?") if @cappuccino
@adhearsion = y? "Use Adhearsion?"

if y?("Store on GitHub?")
  github_username = ask "What's your github username?"
  github_repo_name = ask "What's the github repo name?"
  git :remote => "add github git@github.com:#{github_username}/#{github_repo_name}.git", :push => "github master"
end

git :init

apply "#{@templates_path}/rvm.rb"
apply "#{@templates_path}/cleanup.rb"

gem "nifty-generators", :group => :development

bundle

git :add => ".", :commit => "-m 'Base Rails app (with nifty generators)'"

say "Setting up the staging environment"
run "cp config/environments/production.rb config/environments/staging.rb"
git :add => ".", :commit => "-m 'Add staging environment'"

apply "#{@templates_path}/database.rb"
apply "#{@templates_path}/testing.rb"
apply "#{@templates_path}/authorization.rb"
apply "#{@templates_path}/views.rb"

puts "Using has_scope..."
gem "has_scope"
bundle
git :add => ".", :commit => "-m 'Use has_scope'"

puts "Using simple_enum..."
gem "simple_enum"
bundle
git :add => ".", :commit => "-m 'Use simple_enum'"

puts "Using andand..."
gem "andand"
bundle
git :add => ".", :commit => "-m 'Use andand'"

puts "Annotating models..."
gem "annotate-models", :group => :development
bundle
run "annotate" # FIXME: reload shell first
git :add => ".", :commit => "-m 'Annotate models'"

if @adhearsion
  gem "adhearsion"
  gem "ahn-rails"
  bundle
  run "ahn create adhearsion" # FIXME: reload shell first
  git :add => ".", :commit => "-m 'Add an Adhearsion app'"
end
