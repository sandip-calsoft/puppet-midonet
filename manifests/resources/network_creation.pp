# == Resource: midonet::resources::network_creation
#
# Creates external and tenant networks and creates their ports
#
# === Parameters
#
# [*api_endpoint*]
#   Midonet API endpoint
# [*keystone_username*]
#   Keystone username
# [*keystone_password*]
#   KKeystone Password
# [*tenant_name*]
#   Tenant Name
# [*controller_ip*]
#   Controller node ip
# [*controller_neutron_port*]
#   Controller neutron port
# [*network external*]
#   Name of the external network
# [*allocation_pools*]
#   Allocation Pools for the external subnets
# [*gateway_ip*]
#   Gateway ip
# [*subnet_cidr*]
#   Subnet cidr ( ex. 172.17.0.0/24 )
# [*subnet_name*]
#   Subnet name ( ex. ext-subnet)
# [*edge_router_name*]
#   Edge Router Name
# [*edge_network_name*]
#   Edge Network Name
# [*edge_subnet_name*]
#   Edge subnet name
# [*edge_cidr*]
#   Edge cidr ( ex. 172.17.0.0/24)
# [*port_name*]
#   Port name
# [*port_fixed_ip*]
#   Port fixed ip
# [*port_interface_name*]
#   Port interface name ( in the old-fashioned form , like eth0, eth1...)
#
#
# === Examples
#
#  network_creation(
#   api_endpoint            => 'http://127.0.0.1:8181/midonet-api',
#   keystone_username       => 'midogod',
#   keystone_password       => 'testmido',
#   tenant_name             => 'admin',
#   controller_ip           => '127.0.0.1',
#   controller_neutron_port => '9696',
#   network_external        => 'ext-net',
#   allocation_pools        => ['start=172.17.0.10,end=172.17.0.200'],
#   gateway_ip              => '172.17.0.3',
#   subnet_cidr             => '172.17.0.0/24',
#   subnet_name             => 'ext-subnet',
#   edge_router_name        => 'edge-router',
#   edge_network_name       => 'net-edge1-gw1',
#   edge_subnet_name        => 'subnet-edge1-gw1',
#   edge_cidr               => '172.17.0.0/24',
#   port_name               => 'testport',
#   port_fixed_ip           => '172.17.0.3',
#   port_interface_name     => 'eth1'
#
# )
#
# === Authors
#
# Midonet (http://midonet.org)
#
# === Copyright
#
# Copyright (c) 2015 Midokura SARL, All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
define midonet::resources::network_creation(
  $api_endpoint            = 'http://127.0.0.1:8181/midonet-api',
  $keystone_username       = 'midogod',
  $keystone_password       = 'testmido',
  $tenant_name             = 'admin',
  $controller_ip           = '127.0.0.1',
  $controller_neutron_port = '9696',
  $network_external        = 'ext-net',
  $allocation_pools        = ['start=172.17.0.10,end=172.17.0.200'],
  $gateway_ip              = '172.17.0.3',
  $subnet_cidr             = '172.17.0.0/24',
  $subnet_name             = 'ext-subnet',
  $edge_router_name        = 'edge-router',
  $edge_network_name       = 'net-edge1-gw1',
  $edge_subnet_name        = 'subnet-edge1-gw1',
  $edge_cidr               = '172.17.0.0/24',
  $port_name               = 'testport',
  $port_fixed_ip           = '172.17.0.3',
  $port_interface_name     = 'eth1'

) {


  $neutron_auth_creds = {
    'neutron_auth_uri' => "http://${controller_ip}:${controller_neutron_port}",
    'admin_username'        => $keystone_username,
    'admin_password'        => $keystone_password,
    'admin_tenant_name'     => $tenant_name,
}

  neutron_network { $network_external:
    external            => true,
    shared              => true,
    neutron_credentials => $neutron_auth_creds
    } ->

  neutron_subnet { $subnet_name:
    allocation_pools    => $allocation_pools,
    enable_dhcp         => false,
    gateway_ip          => $gateway_ip,
    cidr                => $subnet_cidr,
    network_name        => $network_external,
    neutron_credentials => $neutron_auth_creds
  } ->

  neutron_router { $edge_router_name:
    neutron_credentials => $neutron_auth_creds
  } ->

  neutron_router_interface { "${edge_router_name}:${subnet_name}":
    neutron_credentials => $neutron_auth_creds
  } ->

  neutron_network { $edge_network_name:
    tenant_id             => $tenant_name,
    provider_network_type => 'uplink',
    neutron_credentials   => $neutron_auth_creds
  } ->

  neutron_subnet { $edge_subnet_name:
    enable_dhcp         => false,
    cidr                => $edge_cidr,
    tenant_id           => $tenant_name,
    network_name        => $edge_network_name,
    neutron_credentials => $neutron_auth_creds
  } ->

  neutron_port { $port_name:
    network_name        => $edge_network_name,
    binding_host_id     => $::hostname,
    binding_profile     => {
      'interface_name' => c7_int_name($port_interface_name)
    },
    fixed_ip            => $port_fixed_ip,
    neutron_credentials => $neutron_auth_creds
  } ->

  neutron_router_interface { "${edge_router_name}:null":
    port                => $port_name,
    neutron_credentials => $neutron_auth_creds
  }

}
