# == Class: softec_postfix::monitoring
#
# This class configure Postfix Mailqueue Monitoring
#
# === Parameters
#
# [*warning*]
# Warning level for Postfix queue mails.
#
# [*critical*]
# Critical level for Postfix queue mails.
#
# [*queue*]
# Postfix queue.
#
# === Authors
#
# Lorenzo Cocchi <lorenzo.cocchi@softecspa.it>


class softec_postfix::monitoring (
  $warning  = 30,
  $critical = 50,
  $queue    = 'deferred',
) {

  $plugin_name   = 'check_postfix_mailqueue'
  $contrib_dir   = '/usr/lib/nagios/plugins/contrib'

  if ! is_integer($warning) {
      fail('Variable $warning must be integer')
  }

  if ! is_integer($critical) {
      fail('Variable $critical must be integer')
  }

  if ! is_string($queue) {
      fail('Variable $queue must to be string')
  }

  nrpe::check{ 'check_postfix_mailqueue':
    contrib    => true,
    binaryname => $plugin_name,
    checkname  => $plugin_name,
    params     => "-w ${warning} -c ${critical} -q ${queue}",
    sudo       => true,
  }

  softec_sudo::conf { "nagios_${plugin_name}":
    priority => 99,
    content  => "nagios ALL=(ALL) NOPASSWD: ${contrib_dir}/${plugin_name}",
  }

}
