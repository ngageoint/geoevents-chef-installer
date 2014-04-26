geoevents_pkgs = "build-essential python-dev libpq-dev libpng-dev libfreetype6 libfreetype6-dev".split

geoevents_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

python_virtualenv node['geoevents']['virtualenv']['location'] do
  interpreter "python2.7"
  action :create
end

python_pip "uwsgi" do
  virtualenv node['geoevents']['virtualenv']['location']
end

git node['geoevents']['location'] do
  repository node['geoevents']['git_repo']['location']
  revision node['geoevents']['git_repo']['branch']
  action :sync
  notifies :run, "execute[install_geoevents_dependencies]", :immediately
  notifies :run, "bash[sync_db]"
  notifies :run, "execute[install_map_fixtures]"
end

execute "install_geoevents_dependencies" do
  command "#{node['geoevents']['virtualenv']['location']}/bin/pip install -r geoevents/requirements.txt"
  cwd node['geoevents']['location']
  action :nothing
  user 'root'
end

execute "install_map_fixtures" do
  command "sudo #{node['geoevents']['virtualenv']['location']}/bin/activate && sudo paver delayed_fixtures"
  cwd node['geoevents']['location']
  action :nothing
  user 'root'
end

template "geoevents_local_settings" do
  source "local_settings.py.erb"
  path "#{node['geoevents']['virtualenv']['location']}/local_settings.py"
  variables ({:database => node['geoevents']['settings']['DATABASES']['default']})
end

link "local_settings_symlink" do
  link_type :symbolic
  to "#{node['geoevents']['virtualenv']['location']}/local_settings.py"
  target_file "#{node['geoevents']['location']}/geoevents/local_settings.py"
  not_if do File.exists?("#{node['geoevents']['location']}/geoevents/local_settings.py") end
end

hostsfile_entry node['geoevents']['database']['address'] do
  hostname node['geoevents']['database']['hostname']
  only_if do node['geoevents']['database']['hostname'] && node['geoevents']['database']['address'] end
  action :append
end

include_recipe 'geoevents::postgis'
include_recipe 'geoevents::database'

directory node['geoevents']['logging']['location'] do
  action :create
end

directory node['geoevents']['settings']['static_root'] do
  owner "www-data"
  mode 00755
  action :create
  recursive true
end

directory "#{node['geoevents']['settings']['static_root']}/CACHE" do
  owner "www-data"
  mode 00755
  action :create
  recursive true
end

directory "#{node['geoevents']['settings']['static_root']}/CACHE/js" do
  owner "www-data"
  mode 00755
  action :create
  recursive true
end

directory "#{node['geoevents']['settings']['static_root']}/CACHE/css" do
  owner "www-data"
  mode 00755
  action :create
  recursive true
end

bash "sync_db" do
  code "source #{node['geoevents']['virtualenv']['location']}/bin/activate && paver sync"
  cwd "#{node['geoevents']['location']}"
  action :nothing
end

execute "collect_static" do
  command "#{node['geoevents']['virtualenv']['location']}/bin/python manage.py collectstatic --noinput"
  cwd "#{node['geoevents']['location']}"
  action :nothing
end

bash "install_fixtures" do
  code "source #{node['geoevents']['virtualenv']['location']}/bin/activate && paver delayed_fixtures"
  cwd "#{node['geoevents']['location']}"
  user 'postgres'
  action :nothing
end

template "geoevents_uwsgi_ini" do
  path "#{node['geoevents']['virtualenv']['location']}/geoevents.ini"
  source "geoevents.ini.erb"
  action :create_if_missing
  notifies :run, "execute[start_django_server]"
end

include_recipe 'geoevents::nginx'

start_geoevents = "#{node['geoevents']['virtualenv']['location']}/bin/uwsgi --ini #{node['geoevents']['virtualenv']['location']}/geoevents.ini &"

execute "start_django_server" do
  command start_geoevents
end

file "/etc/cron.d/geoevents_restart" do
  content "@reboot root #{node['geoevents']['virtualenv']['location']}/bin/uwsgi --ini #{node['geoevents']['virtualenv']['location']}/geoevents.ini &"
  mode 00755
  action :create_if_missing
end
