gem_package "pg" do
  action :install
end

postgresql_connection_info = {
  :host     => node['geoevents']['database']['hostname'],
  :port     => node['geoevents']['database']['port'],
  :username => 'postgres',
  :password => node['postgresql']['password']['postgres']
}

geoevents_db = node['geoevents']['settings']['DATABASES']['default']

# Create the geoevents user
postgresql_database_user geoevents_db[:user] do
    connection postgresql_connection_info
    password geoevents_db[:password]
    action :create
end

# Create the geoevents database
postgresql_database geoevents_db[:name] do
  connection postgresql_connection_info
  template node['postgis']['template_name']
  owner geoevents_db[:user]
  action :create
  notifies :run, "bash[install_fixtures]"
end

postgresql_database 'set user' do
  connection   postgresql_connection_info
  database_name geoevents_db[:name]
  sql 'grant select on geometry_columns, spatial_ref_sys to ' + geoevents_db[:user] + ';'
  action :query
end
