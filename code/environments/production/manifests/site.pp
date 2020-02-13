node 'ec2-34-253-99-219.eu-west-1.compute.amazonaws.com' { # Applies only to mentioned node; if nothing mentioned, applies to all.
file { '/tmp/puppetesttdir': # Resource type file
 ensure => 'directory', # Create as a diectory
 owner => 'root', # Ownership
 group => 'root', # Group Name
 mode => '0755', # Directory permissions
}
file { '/tmp/puppettestfile': # Resource type file
 ensure => 'absent', # Make sure it exists
 owner => 'root', # Ownership
 group => 'root', # Group Name
 mode => '0644', # File permissions
 content => "This File is created by Puppet Server"
}

include ::collectd

class { 'collectd::plugin::apache': instances => { 'vc' => {
    'url' => 'http://0.0.0.0:88/server-status?auto', }, },
  }
class{'kerberos':
  kadmin_hostname => $::fqdn,
  master_password => 'strong-master-password',
  realm           => 'MONKEY_ISLAND',
}
$princ = "host/${::fqdn}@${::kerberos::realm}"
  kerberos::principal{$princ:
    ensure     => present,
    attributes => {
      requires_preauth => true,
    },
    policy     => 'default_host',
  }
  -> kerberos::keytab{'/etc/krb5.keytab':
    principals => [$princ],
  }

  kerberos::policy{'default':
    ensure     => 'present',
    minlength  => 6,
    history    => 2,
    maxlife    => '365 days 0:00:00',
  }

  kerberos::policy{'default_host':
    ensure     => 'present',
    minlength  => 8,
  }
}
