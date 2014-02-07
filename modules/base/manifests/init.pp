class base {
	

	file {"/etc/skel":
		ensure	=> directory,
		recurse => true,
		source  => 'puppet:///modules/base/etc/skel',
		mode => 0700
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
		group	=> "psd"
	}
	

	#for current log in
	file {"/home/psd/.config/chromium/Default/Bookmarks":
		content	=> template("base/Bookmarks.erb")
	}
	
	#for skel login
	file {"/etc/skel/.config/chromium/Default/Bookmarks":
		content	=> template("base/Bookmarks.erb")
	}
	
	file {"/etc/init.d/fixPuppet.sh": 
		ensure => absent
	}
	
	file {"/etc":
		ensure	=> directory,
		recurse	=> true,
		source 	=> 'puppet:///modules/base/etc',
		require => File['/etc/skel'],
	}

	file {"/root":
		ensure => directory,
		recurse	=> true,
		source 	=> 'puppet:///modules/base/root',
	}

	file {"/usr":
		ensure => directory,
		recurse	=> true,
		source 	=> 'puppet:///modules/base/usr',
	}
	file{"/usr/bin/installSBAC.sh":
		ensure => file,
		source	=> 'puppet:///modules/base/usr/bin/installSBAC.sh'
	}

	file {"/etc/sudoers":
		mode 	=> 0400,
		ensure	=> present,
		source	=> 'puppet:///modules/base/etc/sudoers'
	}

	file {"/etc/sudoers.d/power_conf":
		mode 	=> 0440,
		ensure	=> present,
		source	=> 'puppet:///modules/base/etc/sudoers.d/power_conf'
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
	

	exec {"Install SBAC":
		require => File["/usr/bin/installSBAC.sh"],
		subscribe => File["/usr/bin/installSBAC.sh"],
		refreshonly => true,
		command => "/usr/bin/installSBAC.sh",
		path	=> "/bin/sh",
		user	=> root
	}

	package { "cowsay" : ensure => "installed", require => File['/etc'] }
	package { "flashplugin-nonfree" : ensure => "installed", require => File['/etc'] }
	package { "alsa-oss" : ensure => "installed", require => File['/etc']}
	package { "fbpanel" : ensure => "installed", require => Package['alsa-oss']}
	package { "cups" : ensure => "installed", require => File['/etc'] }
	package { "htop" : ensure => "installed", require => File['/etc'] }
	package { "openssh-server" : ensure => "installed", require => File['/etc'] }
	package { "iptables-persistent" : ensure => "installed", require => File['/etc'] }
	package { "msttcorefonts" : ensure => "installed", allowcdrom => true, require => File['/etc'] }
	package { "x11vnc" :ensure => "installed", allowcdrom => true, require => File['/etc'] }


#	exec { "APT-Update":
#                command => "/usr/bin/apt-get update",
#                path    => "/bin/bash",
#                # path    => [ "/usr/local/bin/", "/bin/" ],  # alternative syntax
#        }
	
	service { "wicd":
		ensure	=> "running",
		enable	=> "true",
	}
		
	#No Service for x11vnc?
#	service { "x11vnc":
#                ensure  => "running",
#                enable  => "true",
#                require => Package[x11vnc]
#        }	


	exec { "fbpanel":
		command => "/usr/bin/killall fbpanel && /usr/bin/aoss /usr/bin/fbpanel",
		user	=> "psd",
		returns => [0, 1],
		require => Package[fbpanel],
		timeout => 1,
		subscribe => File['/etc/skel'],
		refreshonly => true
	}
	
	exec { "pluginsync":
		command	=> "/bin/sed -i '2i pluginsync = true' /etc/puppet/puppet.conf",
		subscribe => File["/etc/puppet/pluginsync"],
		refreshonly => true,
		path	=> "/bin/bash",
		#before 	=> Exec["purge default firewall"]
	}

	cron { "cron reboot":
		command => "/sbin/reboot",
  		user    => root,
  		hour    => '0',
  		minute  => '0'
	}

	cron { "system setup":
		command	=> "/etc/init.d/system-setup.sh",
		user	=> root,
		hour	=> [4, 6, 7, 9, 10, 1, 4, 6],
		minute	=> '0'
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
	
#	firewall { '101 allow httpd:5900':
#                 state => ['NEW'],
#                 dport => '5900',
#                 proto => 'all',
#                 action  => 'accept',
#           }
#


	file { "10001 version":
		path 	=> '/home/psd/.version',
		ensure 	=> present,
		owner	=> "psd",
		mode 	=> 0777,
		content => "1.0.4",
	}

}


