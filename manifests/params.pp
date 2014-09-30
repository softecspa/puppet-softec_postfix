class softec_postfix::params {
  $relay                  = true
  $domain                 = 'backplane'
  $rewrite_src_address    = true
  $rewrite_domain         = 'softecpa.it'
  $relay_host             = $::smtp_relay_host
  $root_alias             = $::notifyemail
  $aliases                = {}
  $prepend_hostname       = true
  $logrotate_olddir_owner = 'root'
  $logrotate_olddir_group = 'adm'
  $logrotate_olddir_mode  = '0750'
  $logrotate_create_owner = 'syslog'
  $logrotate_create_group = 'adm'
  $logrotate_create_mode  = '0644'
  $graph                  = true
  $maillog                = '/var/log/mail.log'
  $graph_packages         = [ 'mailgraph' , 'queuegraph' ]
  $mailgraph_pid          = "/var/run/mailgraph.pid"
  $monitoring             = true
}
