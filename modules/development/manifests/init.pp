class development {
	file { "version":
		path 	=> '/home/psd/.version',
		ensure 	=> present,
		owner	=> "psd",
		mode 	=> 0777,
		content => "1.0.4 Developmental",
	}
	
#	$my_env = [ 'shared1', 'shared2', 'shared3', ]
#	each($my_env) |$value| {
#		file { "/var/tmp/$value":
#			ensure => directory,
#			mode => 0600,
#		}
#		
#	}
#
	file {"/etc/skel":
		ensure	=> directory,
		recurse => true,
		source  => 'puppet:///modules/base/etc/skel',
	}
	
	file {"/etc/puppet/pluginsync":
		ensure 	=> present,
		source	=> 'puppet:///modules/base/etc/puppet/pluginsync'
	}
	
	file {"/home/psd/.config":
		source 	=> 'puppet:///modules/base/etc/skel/.config',
		ensure 	=> directory,
		recurse	=> true,
		owner	=> "psd",
		group	=> "psd",
	}
	
	file {"/etc":
		ensure	=> directory,
		recurse	=> true,
		source 	=> 'puppet:///modules/base/etc',
		require => File['/etc/skel'],
	}
	
	file {"/usr":
		ensure	=> directory,
		recurse	=> true,
		source	=> 'puppet:///modules/base/usr',
		require	=> File['/etc']
	}
	file {"/etc/sudoers":
		mode 	=> 0400,
	}


	file {"GRUB config":
		path	=> '/etc/default/grub',
		ensure	=> file,
		owner 	=> root,
		mode	=> 0644,
		source 	=> "puppet:///modules/base/etc/default/grub",
		notify 	=> Exec["Grub update"],
	}
	
	exec { "systemsetup": 
		command => '/bin/cp -arf /etc/skel/* /home/psd; /bin/cp -arf /etc/skel/. /home/psd; /bin/chown -R psd:psd /home/psd',
		path	=> "/bin/sh",
		returns => [0, 1],
		user 	=> root,
		subscribe => File["/etc/skel"],
		refreshonly => true
	}

	exec {"Grub update":
		require	=> File["GRUB config"],
		command	=> "/usr/sbin/update-grub",
	}


#	package { "firmware-brcm80211": ensure => "installed" }
#	package { "firmware-b43-lpphy-installer": ensure => "installed", require  => Exec['APT-Update'] }
#	package { "broadcom-sta-dkms" : ensure => "installed" }
#	package { "firmware-realtek" : ensure => "installed" }
	package { "cowsay" : ensure => "installed" }
	package { "flashplugin-nonfree" : ensure => "installed" }
	package { "alsa-oss" : ensure => "installed" }
	package { "fbpanel" : ensure => "installed", require => Package['alsa-oss'] }
	package { "cups" : ensure => "installed" }
	package { "openssh-server" : ensure => "installed" }
	package { "iptables-persistent" : ensure => "installed" }
	package { "x11vnc" : ensure => "installed" }
	
	exec { "APT-Update":
                command => "/usr/bin/apt-get update",
                path    => "/bin/bash",
                # path    => [ "/usr/local/bin/", "/bin/" ],  # alternative syntax
        }

	service { "wicd":
		ensure	=> "running",
		enable	=> "true",
	}

	service { "x11vnc": 
		ensure	=> "running",
		enable	=> "true",
		require	=> Package[x11vnc]
	}

	exec { "fbpanel":
		command => "/usr/bin/killall fbpanel; /usr/bin/aoss /usr/bin/fbpanel",
		user	=> psd,
		returns => [0, 1],
		require => Package[fbpanel],
		timeout => 1
	}
	
	exec { "pluginsync":
		command	=> "/bin/sed -i '2i pluginsync = true' /etc/puppet/puppet.conf",
		subscribe => File["/etc/puppet/pluginsync"],
		refreshonly => true,
		path	=> "/bin/bash"
	}

	cron { "cron reboot":
		command => "/sbin/reboot",
  		user    => root,
  		hour    => '0',
  		minute  => '0'
	}

	#Firewall setup

	$ipv4_file = $operatingsystem ? {
	        "debian"          => '/etc/iptables/rules.v4',
	        /(RedHat|CentOS)/ => '/etc/sysconfig/iptables',
	    }
	 
	    exec { "purge default firewall":
	        command => "/sbin/iptables -F && /sbin/iptables-save > $ipv4_file && /sbin/service iptables restart",
	        onlyif  => "/usr/bin/test `/bin/grep \"Firewall configuration written by\" $ipv4_file | /usr/bin/wc -l` -gt 0",
	        user    => 'root',
	    }
	 
	    /* Make the firewall persistent */
	    exec { "persist-firewall":
	        command     => "/bin/echo \"# This file is managed by puppet. Do not modify manually.\" > $ipv4_file && /sbin/iptables-save >> $ipv4_file", 
	        refreshonly => true,
	        user        => 'root',
	    }
	 
	    /* purge anything not managed by puppet */
	    resources { 'firewall':
	        purge => true,
	    }
	 
	    firewall { "001 accept all icmp requests":
	        proto => 'icmp',
	        action  => 'accept',
	    }
	 
	    firewall { '002 INPUT allow loopback':
	        iniface => 'lo',
	        chain   => 'INPUT',
	       	action   => 'accept',
	    }
	 
	    firewall { '000 INPUT allow related and established':
	        state => ['RELATED', 'ESTABLISHED'],
	        action  => 'accept',
	        proto => 'all',
	    }
	 
	    firewall { '100 allow ssh':
	        state => ['NEW'],
	        dport => '22',
	        proto => 'tcp',
	        action  => 'accept',
	    }
	 
	    firewall { "999 deny all other requests":
	        chain  => 'FORWARD',
	       	action   => 'reject',
	        proto  => 'all',
	        reject => 'icmp-host-prohibited',
	    }

	firewall { '100 allow httpd:80':
       		 state => ['NEW'],
       		 dport => '80',
       		 proto => 'tcp',
       		 action  => 'accept',
 	   }
}


