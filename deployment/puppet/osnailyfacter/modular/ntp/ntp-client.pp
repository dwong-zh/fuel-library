notice('MODULAR: ntp-client.pp')

$management_vrouter_vip  = hiera('management_vrouter_vip')
$ntp_servers             = hiera_array('ntp_servers', [$management_vrouter_vip])
$nodes_hash              = hiera('nodes', {})
$roles                   = node_roles($nodes_hash, hiera('uid'))

if !(member($roles, 'controller') or member($roles, 'primary-controller')) {
  class { 'ntp':
    servers         => $ntp_servers,
    service_ensure  => 'running',
    service_enable  => true,
    disable_monitor => true,
    iburst_enable   => true,
    tinker          => true,
    panic           => '0',
    stepout         => '5',
    minpoll         => '3',
  }

  include ntp::params
  tweaks::ubuntu_service_override { 'ntpd':
    package_name => $ntp::params::package_name,
    service_name => $ntp::params::service_name,
  }
}
