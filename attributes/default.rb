# override settings in included cookbooks, DO NOT CHANGE
# versions are from https://github.com/nathanmarz/storm/wiki/Settings-up-a-Storm-cluster 

override['python']['install_method'] = 'source'
override['python']['version'] = '2.6.6'
override['python']['checksum'] = ''
override['java']['jdk_version'] = 6
override['zeromq']['version'] = '2.1.7'
override['zeromq']['sha1_sum'] = ''

# recipe defaults

default['storm']['user'] = 'storm'
default['storm']['group'] = 'storm'
default['storm']['version'] = '0.9.0.1'
default['storm']['url'] = "https://dl.dropboxusercontent.com/s/tqdpoif32gufapo/storm-0.9.0.1.tar.gz"
default['storm']['jzmq']['url'] = 'https://github.com/nathanmarz/jzmq/archive/master.tar.gz'
default['storm']['zookeeper_hosts'] = []
default['storm']['data_dir'] = '/var/storm'
default['storm']['install_dir'] = '/opt/storm'
default['storm']['nimbus_host'] = ''
default['storm']['supervisor_ports'] = ['6700', '6701', '6702', '6703']
#default['storm']['checksum'] = ''
#default['storm']['jzmq']['checksum'] = ""
