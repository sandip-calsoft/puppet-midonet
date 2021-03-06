# == Class: midonet::mem
#
# Install and configure Midokura Enterprise MidoNet (MEM)
#
# === Parameters
#
# [mem_package]
# Name of the MEM package
#
# [mem_install_path]
# Installation path of MEM package
#
# [api_host]
#   Configures the MidoNet REST API's host:port combination. This can be either
#   the API host's host name and Tomcat port, or if proxied, e.g via Apache,
#   the corresponding proxy host name and port.
#   e.g. "api_host": "http://host:port"
#
# [api_version]
#   The default value for the api_version is set to latest version. In case you
#   are using and older MidoNet REST API, change the version accordingly.
#   Note: The MidoNet Manager supports the following API versions: 1.8 and 1.9
#   e.g. "api_version": "1.9"
#
# [api_token]
#   If desired, auto-login can be enabled by setting the value of api_token to
#   your Keystone token.
#   e.g. "api_token": keystone_token
#
# [api_namespace]
#   The default value for the api_namespace is set to midonet-api which usually
#   does not have to be changed.
#   Default value: "api_namespace": "midonet-api"
#
# [login_host]
#   Configures the authentication host's host:port combination. Usually your
#   authentication server, e.g. Keystone, is accessible from the same address as
#   the MidoNet REST API, so the host:port combination should be the same as for
#   the API host ("api_host"). Should the authentication server be located on a
#   different host then the MidoNet REST API, change this parameter accordingly.
#   e.g "login_host": "http://host:port"
#
# [trace_api_host]
#   Configures the trace requests management API host:port combination. It is
#   usually the same as the "api_host" but could be setup to run on a different
#   server. This can be either the API host's host name and Tomcat port, or if
#   proxied, e.g via Apache, the corresponding proxy host name and port.
#   e.g. "trace_api_host": "http://host:port"
#
# [traces_ws_url]
#   Configures the websocket endpoint host:port combination. This endpoint is
#   used by the Flow Tracing feature in Midonet Manager.
#   e.g. "trace_ws_url": "ws://host:port"
#
# [agent_config_api_host]
#   Configures the Agent Configuration API host:port combination. The Host is
#   usually the same as the Midonet REST API and the default port is 8459.
#   e.g. "agent_config_api_host": "http://host:port"
#
# [agent_config_api_namespace]
#   The default value for the 'agent_config_api_namespace' is set to 'conf'
#   which usually does not have to be changed.
#   Default value: "api_namespace": "conf"
#
# [poll_enabled]
#   The Auto Polling will seamlessly refresh Midonet Manager data periodically.
#   It is enabled by default and can be disabled in Midonet Manager's Settings
#   section directly through the UI. This will only disable it for the duration
#   of the current session. It can also be disabled permanently by changing the
#   'poll_enabled' parameter to 'false'
#
# === Authors
#
# Midonet (http://midonet.org)
#
# === Copyright
#
# Copyright (c) 2016 Midokura SARL, All Rights Reserved.

class midonet::mem(
# Midonet Manager installation options
  $mem_package                    = $::midonet::params::mem_package,
  $mem_install_path               = $::midonet::params::mem_install_path,
  $mem_api_host                   = $::midonet::params::mem_api_host,
  $mem_login_host                 = $::midonet::params::mem_login_host,
  $mem_trace_api_host             = $::midonet::params::mem_trace_api_host,
  $mem_traces_ws_url              = $::midonet::params::mem_traces_ws_url,
  $mem_api_namespace              = $::midonet::params::mem_api_namespace,
  $mem_api_version                = $::midonet::params::mem_api_version,
  $mem_api_token                  = $::midonet::params::mem_api_token,
  $mem_agent_config_api_namespace = $::midonet::params::mem_agent_config_api_namespace,
  $mem_analytics_ws_api_url       = $::midonet::params::mem_analytics_ws_api_url,
  $mem_poll_enabled               = $::midonet::params::mem_poll_enabled,
  $mem_login_animation_enabled    = $::midonet::params::mem_login_animation_enabled,
  $mem_config_file                = $::midonet::params::mem_config_file,

) inherits midonet::params {

  include midonet::repository

  validate_string($mem_package)
  validate_string($mem_install_path)

  validate_string($mem_api_host)
  validate_string($mem_login_host)
  validate_string($mem_trace_api_host)
  validate_string($mem_traces_ws_url)
  validate_string($mem_api_namespace)
  validate_bool($mem_api_token)
  validate_string($mem_api_version)
  validate_string($mem_config_file)
  validate_string($mem_agent_config_api_namespace)
  validate_string($mem_analytics_ws_api_url)
  validate_bool($mem_poll_enabled)
  validate_bool($mem_login_animation_enabled)


  package { 'midonet-manager':
    ensure => installed,
    name   => $mem_package
  }

  file { 'midonet-manager-config':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    path    => "${mem_install_path}/config/client.js",
    content => template("${module_name}/client.js.erb"),
    require => Package['midonet-manager']
  }

  include ::midonet::mem::vhost
}

