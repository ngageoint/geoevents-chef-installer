default['geoevents']['debug'] = true
default['geoevents']['logging']['location'] = '/var/log/geoevents'
default['geoevents']['virtualenv']['location'] = '/var/lib/geoevents'
default['geoevents']['location'] = '/usr/src/geoevents'
default['geoevents']['git_repo']['location'] = 'https://github.com/ngageoint/geoevents.git'
default['geoevents']['git_repo']['branch'] = 'master'
default['postgresql']['password']['postgres'] = 'geoevents'

default['geoevents']['database']['address'] = '127.0.0.1'
default['geoevents']['database']['hostname'] = 'geoevents-database'
default['geoevents']['database']['name'] = 'geoevents'
default['geoevents']['database']['user'] = 'geoevents'
default['geoevents']['database']['password'] = 'geoevents'
default['geoevents']['database']['port'] = '5432'

default[:postgis][:version] = '2.0.4'
default['postgis']['template_name'] = 'template_postgis'
default['postgis']['locale'] = 'en_US.utf8'

default['geoevents']['settings']['static_root'] = '/usr/src/geoevents/geoevents/static'
default['geoevents']['settings']['static_url'] = '/static/'

default['geoevents']['settings']['DATABASES'] = {
    :default=>{
        :name => node['geoevents']['database']['name'],
        :user => node['geoevents']['database']['user'],
        :password => node['geoevents']['database']['password'],
        :host => node['geoevents']['database']['hostname'],
        :port => node['geoevents']['database']['port']
        },
    }

