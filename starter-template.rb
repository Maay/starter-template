# Application Generator Template
# Modifies a Rails app to use Mongoid and Devise
# Usage: rails new APP_NAME -m https://github.com/Maay/starter-template/raw/master/starter-template.rb -T -O

# Information and a tutorial: 
# http://github.com/RailsApps/rails3-mongoid-devise/

# Generated using the rails_apps_composer gem:
# https://github.com/RailsApps/rails_apps_composer/

# If you are customizing this template, you can use any methods provided by Thor::Actions
# http://rdoc.info/rdoc/wycats/thor/blob/f939a3e8a854616784cac1dcff04ef4f3ee5f7ff/Thor/Actions.html
# and Rails::Generators::Actions
# http://github.com/rails/rails/blob/master/railties/lib/rails/generators/actions.rb


# >----------------------------[ Initial Setup ]------------------------------<

initializer 'generators.rb', <<-RUBY
Rails.application.config.generators do |g|
end
RUBY

@recipes = ["jquery", "slim", "bootstrap", "mongoid", "action_mailer", "devise", "add_user", "layouts", "seed_database", "users_page", "css_setup", "application_layout", "html5", "navigation", "cleanup", "ban_spiders", "extras", "git"]

def recipes; @recipes end
def recipe?(name); @recipes.include?(name) end

def say_custom(tag, text); say "\033[1m\033[36m" + tag.to_s.rjust(10) + "\033[0m" + "  #{text}" end
def say_recipe(name); say "\033[1m\033[36m" + "recipe".rjust(10) + "\033[0m" + "  Running #{name} recipe..." end
def say_wizard(text); say_custom(@current_recipe || 'wizard', text) end

def ask_wizard(question)
  ask "\033[1m\033[30m\033[46m" + (@current_recipe || "prompt").rjust(10) + "\033[0m\033[36m" + "  #{question}\033[0m"
end

def yes_wizard?(question)
  answer = ask_wizard(question + " \033[33m(y/n)\033[0m")
  case answer.downcase
    when "yes", "y"
      true
    when "no", "n"
      false
    else
      yes_wizard?(question)
  end
end

def no_wizard?(question); !yes_wizard?(question) end

def multiple_choice(question, choices)
  say_custom('question', question)
  values = {}
  choices.each_with_index do |choice,i| 
    values[(i + 1).to_s] = choice[1]
    say_custom (i + 1).to_s + ')', choice[0]
  end
  answer = ask_wizard("Enter your selection:") while !values.keys.include?(answer)
  values[answer]
end

@current_recipe = nil
@configs = {}

@after_blocks = []
def after_bundler(&block); @after_blocks << [@current_recipe, block]; end
@after_everything_blocks = []
def after_everything(&block); @after_everything_blocks << [@current_recipe, block]; end
@before_configs = {}
def before_config(&block); @before_configs[@current_recipe] = block; end


case Rails::VERSION::MAJOR.to_s
when "3"
  case Rails::VERSION::MINOR.to_s
  when "1"
    say_wizard "You are using Rails version #{Rails::VERSION::STRING}."
    @recipes << 'rails 3.1'
  when "0"
    say_wizard "You are using Rails version #{Rails::VERSION::STRING}."
    @recipes << 'rails 3.0'
  else
    say_wizard "You are using Rails version #{Rails::VERSION::STRING} which is not supported."
  end
else
  say_wizard "You are using Rails version #{Rails::VERSION::STRING} which is not supported."
end

# show which version of rake is running
# with the added benefit of ensuring that the Gemfile's version of rake is activated
gemfile_rake_ver = run 'bundle exec rake --version', :capture => true, :verbose => false
say_wizard "You are using #{gemfile_rake_ver.strip}"

say_wizard "Checking configuration. Please confirm your preferences."

# >---------------------------[ Javascript Runtime ]-----------------------------<

prepend_file 'Gemfile' do <<-RUBY
require 'rbconfig'
HOST_OS = RbConfig::CONFIG['host_os']

RUBY
end

if recipes.include? 'rails 3.1'
  append_file 'Gemfile' do <<-RUBY
# install a Javascript runtime for linux
if HOST_OS =~ /linux/i
  gem 'therubyracer', '>= 0.9.8'
end

  RUBY
  end
end

# >---------------------------------[ Recipes ]----------------------------------<


# >--------------------------------[ jQuery ]---------------------------------<

@current_recipe = "jquery"
@before_configs["jquery"].call if @before_configs["jquery"]
say_recipe 'jQuery'

config = {}
config['jquery'] = yes_wizard?("Would you like to use jQuery?") if true && true unless config.key?('jquery')
config['ui'] = yes_wizard?("Would you like to use jQuery UI?") if true && true unless config.key?('ui')
@configs[@current_recipe] = config

# Application template recipe for the rails_apps_composer. Check for a newer version here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/jquery.rb

if config['jquery']
  if recipes.include? 'rails 3.0'
    say_wizard "Replacing Prototype framework with jQuery for Rails 3.0."
    after_bundler do
      say_wizard "jQuery recipe running 'after bundler'"
      # remove the Prototype adapter file
      remove_file 'public/javascripts/rails.js'
      # remove the Prototype files (if they exist)
      remove_file 'public/javascripts/controls.js'
      remove_file 'public/javascripts/dragdrop.js'
      remove_file 'public/javascripts/effects.js'
      remove_file 'public/javascripts/prototype.js'
      # add jQuery files
      inside "public/javascripts" do
        get "https://raw.github.com/rails/jquery-ujs/master/src/rails.js", "rails.js"
        get "http://code.jquery.com/jquery-1.6.min.js", "jquery.js"
        if config['ui']
          get "https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.12/jquery-ui.min.js", "jqueryui.js"
        end
      end
      # adjust the Javascript defaults
      # first uncomment "config.action_view.javascript_expansions"
      gsub_file "config/application.rb", /# config.action_view.javascript_expansions/, "config.action_view.javascript_expansions"
      # then add "jquery rails" if necessary
      gsub_file "config/application.rb", /= \%w\(\)/, "= %w(jquery rails)"
      # finally change to "jquery jqueryui rails" if necessary
      if config['ui']
        gsub_file "config/application.rb", /jquery rails/, "jquery jqueryui rails"
      end
    end
  elsif recipes.include? 'rails 3.1'
    if config['ui']
      inside "app/assets/javascripts" do
        get "https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.12/jquery-ui.min.js", "jqueryui.js"
      end
    else
      say_wizard "jQuery installed by default in Rails 3.1."
    end
  else
    say_wizard "Don't know what to do for Rails version #{Rails::VERSION::STRING}. jQuery recipe skipped."
  end
else
  if config['ui']
    say_wizard "You said you didn't want jQuery. Can't install jQuery UI without jQuery."
  end
  recipes.delete('jquery')
end


# >---------------------------------[ SLIM ]----------------------------------<

@current_recipe = "slim"
@before_configs["slim"].call if @before_configs["slim"]
say_recipe 'slim'

config = {}
config['slim'] = yes_wizard?("Would you like to use Slim instead of ERB?") if true && true unless config.key?('slim')
@configs[@current_recipe] = config

if config['slim']
    gem 'slim'
else
  recipes.delete('slim')
end


# >--------------------------------[ Mongoid ]--------------------------------<

@current_recipe = "mongoid"
@before_configs["mongoid"].call if @before_configs["mongoid"]
say_recipe 'Mongoid'

config = {}
config['mongoid'] = yes_wizard?("Would you like to use Mongoid to connect to a MongoDB database?") if true && true unless config.key?('mongoid')
@configs[@current_recipe] = config

if config['mongoid']
    # for Rails 3.1+, use optimistic versioning for gems
    gem 'bson_ext', '>= 1.3.1'
    gem 'mongoid', '>= 2.3.3'
else
  recipes.delete('mongoid')
end

if config['mongoid']
  after_bundler do
    say_wizard "Mongoid recipe running 'after bundler'"
    # note: the mongoid generator automatically modifies the config/application.rb file
    # to remove the ActiveRecord dependency by commenting out "require active_record/railtie'"
    generate 'mongoid:config'
    # remove the unnecessary 'config/database.yml' file
    remove_file 'config/database.yml'
  end
end


# >-----------------------------[ ActionMailer ]------------------------------<

@current_recipe = "action_mailer"
@before_configs["action_mailer"].call if @before_configs["action_mailer"]
say_recipe 'ActionMailer'


@configs[@current_recipe] = config

# Application template recipe for the rails_apps_composer. Check for a newer version here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/action_mailer.rb

after_bundler do
  say_wizard "ActionMailer recipe running 'after bundler'"
  # modifying environment configuration files for ActionMailer
  gsub_file 'config/environments/development.rb', /# Don't care if the mailer can't send/, '# ActionMailer Config'
  gsub_file 'config/environments/development.rb', /config.action_mailer.raise_delivery_errors = false/ do
  <<-RUBY
config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  # A dummy setup for development - no deliveries, but logged
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default :charset => "utf-8"
RUBY
  end
  gsub_file 'config/environments/production.rb', /config.active_support.deprecation = :notify/ do
  <<-RUBY
config.active_support.deprecation = :notify

  config.action_mailer.default_url_options = { :host => 'yourhost.com' }
  # ActionMailer Config
  # Setup for production - deliveries, no errors raised
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default :charset => "utf-8"
RUBY
  end
  
end


# >--------------------------------[ Devise ]---------------------------------<

@current_recipe = "devise"
@before_configs["devise"].call if @before_configs["devise"]
say_recipe 'Devise'

config = {}
config['devise'] = yes_wizard?("Would you like to use Devise for authentication?") if true && true unless config.key?('devise')
@configs[@current_recipe] = config

if config['devise']
  gem 'devise', '>= 1.5.0'
else
  recipes.delete('devise')
end

if config['devise']
  after_bundler do
    
    say_wizard "Devise recipe running 'after bundler'"
    
    # Run the Devise generator
    generate 'devise:install'

    # Nothing to do (Devise changes its initializer automatically when Mongoid is detected)
    # gsub_file 'config/initializers/devise.rb', 'devise/orm/active_record', 'devise/orm/mongoid'
    
     inject_into_file 'app/controllers/application_controller.rb', :after => "ActionController::Base \n" do
   <<-RUBY
   protect_from_forgery
   before_filter :authenticate_user!
  RUBY
     end
    
  end
end


# >--------------------------------[ AddUser ]--------------------------------<

@current_recipe = "add_user"
@before_configs["add_user"].call if @before_configs["add_user"]
say_recipe 'AddUser'


@configs[@current_recipe] = config

# Application template recipe for the rails_apps_composer. Check for a newer version here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/add_user.rb

after_bundler do
  
  say_wizard "AddUser recipe running 'after bundler'"
  
  if recipes.include? 'devise'
    
    # Generate models and routes for a User
    generate 'devise user'

    # Add a 'name' attribute to the User model
      gsub_file 'app/models/user.rb', /end/ do
  <<-RUBY
  field :name
  validates_presence_of :name
  field :admin, type: Boolean, default: false
  validates_uniqueness_of :name, :email, :case_sensitive => false
  def update_with_password(params={})
    params.delete(:current_password)
    self.update_without_password(params)
  end
end
RUBY
      end
    
      # copy SLIM versions of modified Devise views
      inside 'app/views/devise/registrations' do
        get 'https://raw.github.com/Maay/starter-template/master/files/rails3-mongoid-devise/app/views/devise/registrations/edit.slim', 'edit.slim'
        get 'https://raw.github.com/Maay/starter-template/master/files/rails3-mongoid-devise/app/views/devise/registrations/new.slim', 'new.slim'
      end

       inside 'app/views/devise/sessions' do
          get 'https://raw.github.com/Maay/starter-template/master/files/rails3-mongoid-devise/app/views/devise/sessions/new.slim', 'new.slim'
        end

  end

end


# >-------------------------------[ Layouts ]--------------------------------<

@current_recipe = "Layouts"
@before_configs["layouts"].call if @before_configs["layouts"]
say_recipe 'layouts'


@configs[@current_recipe] = config

after_bundler do
  
  say_wizard "Layouts recipe running 'after bundler'"
  
  # remove the default home page
  remove_file 'public/index.html'
  
  # create a pages controller and view
  generate(:controller, "pages index")

  # set up a simple home page (with placeholder content)
  if recipes.include? 'slim'
    remove_file 'app/views/layouts/application.html.erb'
    inside 'app/views/layouts/' do
       get 'https://raw.github.com/Maay/starter-template/master/files/rails3-mongoid-devise/app/views/layouts/application.slim', 'application.slim'
     end
     
     inside 'app/views/layouts/' do
        get 'https://raw.github.com/Maay/starter-template/master/files/rails3-mongoid-devise/app/views/layouts/_topbar.slim', '_topbar.slim'
      end
      
     remove_file 'app/views/pages/index.html.erb'
     inside 'app/views/pages/' do
        get 'https://raw.github.com/Maay/starter-template/master/files/rails3-mongoid-devise/app/views/pages/index.slim', 'index.slim'
      end
      
     inject_into_file 'app/controllers/pages_controller.rb', :after => "ApplicationController \n" do
   <<-RUBY
   respond_to :html
  RUBY
     end 
     
  else
    remove_file 'app/views/home/index.html.erb'
    create_file 'app/views/home/index.html.erb' do 
    <<-ERB
<h3>Home</h3>
ERB
    end
  end

  # set routes
  gsub_file 'config/routes.rb', /get \"pages\/index\"/, 'root :to => "pages#index"'

end

# >-----------------------------[ SeedDatabase ]------------------------------<

@current_recipe = "seed_database"
@before_configs["seed_database"].call if @before_configs["seed_database"]
say_recipe 'SeedDatabase'


@configs[@current_recipe] = config

# Application template recipe for the rails_apps_composer. Check for a newer version here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/seed_database.rb


after_bundler do

  say_wizard "SeedDatabase recipe running 'after bundler'"

  unless recipes.include? 'mongoid'
    run 'bundle exec rake db:migrate'
  end

  if recipes.include? 'mongoid'
    append_file 'db/seeds.rb' do <<-FILE
puts 'EMPTY THE MONGODB DATABASE'
Mongoid.master.collections.reject { |c| c.name =~ /^system/}.each(&:drop)
FILE
    end
  end

  if recipes.include? 'devise'
    # create a default user
    append_file 'db/seeds.rb' do <<-FILE
puts 'SETTING UP DEFAULT USER LOGIN'
user = User.create! :name => 'First User', :email => 'user@example.com', :password => 'please', :password_confirmation => 'please'
puts 'New user created: ' << user.name
FILE
    end
  end

  run 'bundle exec rake db:seed'

end



# >-------------------------------[ CssSetup ]--------------------------------<

@current_recipe = "css_setup"
@before_configs["css_setup"].call if @before_configs["css_setup"]
say_recipe 'CssSetup'


@configs[@current_recipe] = config

# Application template recipe for the rails_apps_composer. Check for a newer version here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/css_setup.rb

after_bundler do

  say_wizard "CssSetup recipe running 'after bundler'"
  remove_file 'app/assets/stylesheets/application.css'
  inside 'app/assets/stylesheets/' do
    get 'https://raw.github.com/Maay/starter-template/master/files/rails3-mongoid-devise/app/assets/stylesheets/application.css', 'application.css'
  end
  
  inside 'app/assets/images/' do
    get 'https://raw.github.com/Maay/starter-template/master/files/rails3-mongoid-devise/app/assets/images/bg_noise_lg.png', 'bg_noise_lg.png'
  end

end

# >---------------------------------[ Twitter Bootstrap ]---------------------------------<

@current_recipe = "bootstrap"
@before_configs["bootstrap"].call if @before_configs["bootstrap"]
say_recipe 'slim'

config = {}
config['bootstrap'] = yes_wizard?("Would you like to use Twitter Bootstrap for quick layouts prototyping?") if true && true unless config.key?('bootstrap')
@configs[@current_recipe] = config

if config['bootstrap']
   gem 'bootstrap-sass'
   inject_into_file 'app/assets/stylesheets/application.css', :after => "*/ \n" do
 <<-CSS
@import "bootstrap";
CSS
   end
else
  recipes.delete('bootstrap')
end


# >--------------------------------[ Cleanup ]--------------------------------<

@current_recipe = "cleanup"
@before_configs["cleanup"].call if @before_configs["cleanup"]
say_recipe 'Cleanup'


@configs[@current_recipe] = config

# Application template recipe for the rails_apps_composer. Check for a newer version here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/cleanup.rb

after_bundler do

  say_wizard "Cleanup recipe running 'after bundler'"

  # remove unnecessary files
  %w{
    README
    doc/README_FOR_APP
    public/index.html
  }.each { |file| remove_file file }
  
  if recipes.include? 'rails 3.0'
    %w{
      public/images/rails.png
    }.each { |file| remove_file file }
  else
    %w{
      app/assets/images/rails.png
    }.each { |file| remove_file file }
  end
  
  # add placeholder READMEs
  get "https://raw.github.com/Maay/starter-template/master/files/sample_readme.txt", "README"
  get "https://raw.github.com/Maay/starter-template/master/files/sample_readme.textile", "README.textile"
  gsub_file "README", /App_Name/, "#{app_name.humanize.titleize}"
  gsub_file "README.textile", /App_Name/, "#{app_name.humanize.titleize}"

  # remove commented lines from Gemfile
  # thanks to https://github.com/perfectline/template-bucket/blob/master/cleanup.rb
  gsub_file "Gemfile", /#.*\n/, "\n"
  gsub_file "Gemfile", /\n+/, "\n"

end


# >------------------------------[ BanSpiders ]-------------------------------<

@current_recipe = "ban_spiders"
@before_configs["ban_spiders"].call if @before_configs["ban_spiders"]
say_recipe 'BanSpiders'

config = {}
config['ban_spiders'] = yes_wizard?("Would you like to set a robots.txt file to ban spiders?") if true && true unless config.key?('ban_spiders')
@configs[@current_recipe] = config

# Application template recipe for the rails_apps_composer. Check for a newer version here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/ban_spiders.rb

if config['ban_spiders']
  say_wizard "BanSpiders recipe running 'after bundler'"
  after_bundler do
    # ban spiders from your site by changing robots.txt
    gsub_file 'public/robots.txt', /# User-Agent/, 'User-Agent'
    gsub_file 'public/robots.txt', /# Disallow/, 'Disallow'
  end
else
  recipes.delete('ban_spiders')
end

# >----------------------------------[ Git ]----------------------------------<

@current_recipe = "git"
@before_configs["git"].call if @before_configs["git"]
say_recipe 'Git'


@configs[@current_recipe] = config

# Application template recipe for the rails_apps_composer. Check for a newer version here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/git.rb

after_everything do
  
  say_wizard "Git recipe running 'after everything'"
  
  # Git should ignore some files
  remove_file '.gitignore'
  get "https://raw.github.com/Maay/starter-template/master/files/gitignore.txt", ".gitignore"

  

  # Initialize new Git repo
  git :init
  git :add => '.'
  git :commit => "-aqm 'new Rails app generated by Rails Apps Composer gem'"
  # Create a git branch
  git :checkout => ' -b working_branch'
  git :add => '.'
  git :commit => "-m 'Initial commit of working_branch'"
  git :checkout => 'master'
end


@current_recipe = nil

# >-----------------------------[ Run Bundler ]-------------------------------<

say_wizard "Running 'bundle install'. This will take a while."
run 'bundle install'
say_wizard "Running 'after bundler' callbacks."
require 'bundler/setup'
@after_blocks.each{|b| config = @configs[b[0]] || {}; @current_recipe = b[0]; b[1].call}

@current_recipe = nil
say_wizard "Running 'after everything' callbacks."
@after_everything_blocks.each{|b| config = @configs[b[0]] || {}; @current_recipe = b[0]; b[1].call}

@current_recipe = nil
say_wizard "Finished running the rails_apps_composer app template."
say_wizard "Your new Rails app is ready."
