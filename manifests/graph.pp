class softec_postfix::graph (
  $logfile        = params_lookup( 'logfile' ),
  $graph_packages = params_lookup( 'graph_packages' ),
  $mailgraph_pid  = params_lookup( 'mailgraph_pid' ),
) inherits softec_postfix::params {

  package {$softec_postfix::graph::graph_packages:
    ensure  => 'present',
    require => [ Package['rrdtool'] ]
  } ->

  file { '/etc/default/mailgraph':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('softec_postfix/mailgraph.erb'),
    notify  => Service['mailgraph'],
  } ->

  service { 'mailgraph':
    ensure      => 'running',
    enable      => 'true',
    hasrestart  => 'true',
    hasstatus   => 'false',
    status      => "test -e ${softec_postfix::graph::mailgraph_pid}"
  }

  ## queuegraph: l'applicazione viene lanciata con un cron. Si pusha il cron
  ## con il modulo puppet in frequently

  file { '/etc/cron.d/queuegraph':
    ensure  => 'absent',
    before  => Cron::Entry['queuegraph'],
  }

  cron::entry {'queuegraph':
    frequency => 'frequently',
    user      => 'root',
    command   => 'test -x /usr/share/queuegraph/count.sh && /usr/share/queuegraph/count.sh >/dev/null 2>&1',
  }
}
