#
# Cookbook Name:: storm
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
# 
# All rights reserved - Do Not Redistribute
#

include_recipe 'apt'
include_recipe 'build-essential'
include_recipe 'java'

%w(libtool pkg-config unzip uuid-dev libsasl2-dev libssl-dev zlib1g-dev libbz2-dev libgdbm-dev libsqlite3-dev).each do |p|
  package p do
    action :install
  end
end

include_recipe 'zeromq'
include_recipe 'python::source'


# Download JZMQ
remote_file ::File.join(Chef::Config[:file_cache_path], "/jzmq.tar.gz") do
  source node['storm']['jzmq']['url']
  owner 'root'
  mode '0644'
  action :create
end

## Fuck Yeah Outdataed Deps
execute "install jzmq from source" do
  cwd Chef::Config[:file_cache_path]
  command """
    tar -zxf jzmq.tar.gz && \
    cd jzmq-master && \
    sed -i 's/classdist_noinst.stamp/classnoinst.stamp/g' src/Makefile.am && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install
    """
end

storm_name = "storm-#{node['storm']['version']}"

group node['storm']['group'] do
  action :create
end

user node['storm']['user'] do
  gid node['storm']['group']
end

# Download Storm
remote_file ::File.join(Chef::Config[:file_cache_path], "/#{storm_name}.tar.gz") do
  source node['storm']['url']
  owner 'root'
  mode '0644'
  action :create
end

directory "/opt/storm" do
  owner node['storm']['user']
  group node['storm']['group']
  mode '0755'
end

directory node['storm']['data_dir'] do
  owner node['storm']['user']
  group node['storm']['group']
  mode '0755'
end

unless ::File.exist?("/opt/storm/#{storm_name}")
  execute "install storm" do
    cwd Chef::Config[:file_cache_path]
    command """
      tar -C /opt/storm -xzf #{storm_name}.tar.gz && \
      chown -R #{node['storm']['user']}:#{node['storm']['group']} /opt/storm/#{storm_name}
    """
  end
end

template "/opt/storm/#{storm_name}/conf/storm.yaml" do
  source "storm.yaml.erb"
  owner node['storm']['user']
  group node['storm']['group']
  mode '0755'
  action :create
  variables({
    zookeepers: node['storm']['zookeeper_hosts'],
    storm_dir: node['storm']['data_dir'],
    nimbus_host: node['storm']['nimbus_host'],
    supervisor_ports: node['storm']['supervisor_ports']
  })
end


if node['storm']['is_nimbus'] == true || node['fqdn'] == node['storm']['nimbus_host']
  daemons = ['nimbus', 'ui']
else
  daemons = ['supervisor']
end
  
daemons.each do |p|
  init_vars = {
    group: node['storm']['group'],
    user: node['storm']['user'],
    version: node['storm']['version'],
    install_dir: node['storm']['install_dir'],
    process: p
  }

  template "/etc/init/storm-#{p}.conf" do
    source "storm.upstart.conf.erb"
    owner "root"
    group "root"
    variables init_vars
    mode "0644"
  end

  service "storm-#{p}" do
    provider Chef::Provider::Service::Upstart
    supports start: true, restart: true, status: true
    action [:enable, :start]
  end
end
