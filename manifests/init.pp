class softec_postfix (
  $relay                  = params_lookup( 'relay' ),
  $domain                 = params_lookup( 'domain' ),
  $rewrite_src_address    = params_lookup( 'rewrite_src_address' ),
  $rewrite_domain         = params_lookup( 'rewrite_domain' ),
  $relay_host             = params_lookup( 'relay_host' ),
  $root_alias             = params_lookup( 'root_alias' ),
  $aliases                = params_lookup( 'aliases' ),
  $prepend_hostname       = params_lookup( 'prepend_hostname' ),
  $logrotate_olddir_owner = params_lookup( 'logrotate_olddir_owner' ),
  $logrotate_olddir_group = params_lookup( 'logrotate_olddir_group' ),
  $logrotate_olddir_mode  = params_lookup( 'logrotate_olddir_mode' ),
  $logrotate_create_owner = params_lookup( 'logrotate_create_owner' ),
  $logrotate_create_group = params_lookup( 'logrotate_create_group' ),
  $logrotate_create_mode  = params_lookup( 'logrotate_create_mode' ),
  $graph                  = params_lookup( 'graph' ),
  $monitoring             = params_lookup( 'monitoring' ),
)inherits softec_postfix::params {

  validate_bool($monitoring)

  class {'postfix':}

  $configuration = {
    'mydestination' => {value => "${::hostname}.${softec_postfix::domain}, localhost.${softec_postfix::domain}, localhost"},
    'myhostname'    => {value => "${::hostname}.${softec_postfix::domain}"},
    'myorigin'      => {value => '/etc/mailname'},
  }
  create_resources ('postfix::postconf',$configuration,{require => Package[$postfix::package], notify => Service[$postfix::service]})

  if $softec_postfix::relay {
    postfix::postconf {'relayhost':
      value   => $softec_postfix::relay_host,
      require => Package[$postfix::package],
      notify  => Service[$postfix::service]
    }
  }

  $mailname_content = $softec_postfix::prepend_hostname ? {
    true    => "${::hostname}.${softec_postfix::domain}",
    default => $softec_postfix::domain
  }

  augeas { 'mailname':
    context => '/files/etc/mailname',
    changes => "set hostname '$mailname_content'",
    notify  => Service[$postfix::service],
  }

  if $softec_postfix::rewrite_src_address {
    postfix::postconf {'smtp_generic_maps':
      value => 'hash:/etc/postfix/generic'
    }

    file { '/etc/postfix/generic':
      ensure  => present,
      mode    => '0644',
      owner   => root,
      group   => root,
      require => Package[$postfix::package],
      content => "root@${::hostname}.${softec_postfix::domain}   root.${::hostname}@${softec_postfix::rewrite_domain}",
    }

    exec {'postmap_generic':
      command     => 'postmap /etc/postfix/generic',
      refreshonly => true,
      subscribe   => File['/etc/postfix/generic'],
      notify      => Service[$postfix::service]
    }
  }

  $aliases_hash = merge({'root' => $softec_postfix::root_alias},$softec_postfix::aliases)

  class {'postfix::aliases':
    maps  => $softec_postfix::aliases_hash
  }

  class {'softec_postfix::logrotate':
    olddir_owner  => $softec_postfix::logrotate_olddir_owner,
    olddir_group  => $softec_postfix::logrotate_olddir_group,
    olddir_mode   => $softec_postfix::logrotate_olddir_mode,
    create_owner  => $softec_postfix::logrotate_create_owner,
    create_group  => $softec_postfix::logrotate_create_group,
    create_mode   => $softec_postfix::logrotate_create_mode,
  }

  if $softec_postfix::graph {
    include softec_postfix::graph
  }

  if $softec_postfix::monitoring {
    include softec_postfix::monitoring
  }

}
