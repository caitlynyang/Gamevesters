# # Make sure the Apt package lists are up to date, so we're downloading versions that exist.
cookbook_file "apt-sources.list" do
  path "/etc/apt/sources.list"
end
execute 'apt_update' do
  command 'apt-get update'
end

# # Base configuration recipe in Chef.
package "wget"
package "ntp"
cookbook_file "ntp.conf" do
  path "/etc/ntp.conf"
end
execute 'ntp_restart' do
  command 'service ntp restart'
end


# installing web server nginx
package "nginx"
package "git"
package "libpq-dev"

#install and set up postgres db

package "postgresql"

execute 'setup_db' do
  command 'echo "CREATE DATABASE mydb; CREATE USER ubuntu; GRANT ALL PRIVILEGES ON DATABASE mydb TO ubuntu;" | sudo -u postgres psql'
end

cookbook_file "nginx-default" do
  path "/etc/nginx/sites-available/default"
end
execute 'nginx_restart' do
  command 'service nginx restart'
end

execute 'nginx_reload' do
  command 'service nginx reload'
end

# # Rails setup

package "ruby-dev"
package "sqlite3"
package "libsqlite3-dev"
package "zlib1g-dev"
package "nodejs"
package "build-essential"

execute 'install nokigiri first' do
  command 'gem install nokogiri -v 1.6.8.1'
end

execute 'bundler install' do
  command 'gem install bundler --conservative'
end

execute 'bundler' do
  user 'ubuntu'
  cwd '/home/ubuntu/project'
  command 'bundle install'
end

execute 'bundler binstubs' do
  user 'ubuntu'
  cwd '/home/ubuntu/project'
  command 'bundle install --binstubs'
end

execute 'migrate db' do
  user 'ubuntu'
  cwd '/home/ubuntu/project'
  command 'rails db:migrate RAILS_ENV=production'
end

execute 'seed database' do
  user 'ubuntu'
  cwd '/home/ubuntu/project'
  command 'rake db:seed RAILS_ENV=production'
end

execute 'precompile_assets' do
  command 'RAILS_ENV=production bundle exec rake assets:precompile'
  cwd '/home/ubuntu/project'
  user 'ubuntu'
end

#setting up unicorn stuff
cookbook_file "unicorn_rails" do
  path "/etc/init.d/unicorn_rails"
end

execute "permissions" do 
  command "chmod +x /etc/init.d/unicorn_rails"
end

execute 'unicorn' do
  command 'update-rc.d unicorn_rails defaults'
end

execute 'startup' do
  command 'service unicorn_rails start'
end

execute 'whenever_cron_tasks' do
  command 'whenever --update-crontab'
  cwd 'home/ubuntu/project'
  user 'ubuntu'
end
