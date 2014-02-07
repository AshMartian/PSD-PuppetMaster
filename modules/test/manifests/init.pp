class test {
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
	
	file {"/home/psd/.config/chromium/Default/Bookmarks":
		content	=> template("base/Bookmarks.erb")
	}

	file {"/etc/skel/.config/chromium/Default/Bookmarks":
		content	=> template("base/Bookmarks.erb")
	}

	file {"/etc":
		ensure	=> directory,
		recurse	=> true,
		source 	=> 'puppet:///modules/base/etc',
		require => File['/etc/skel'],
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


#	package { "firmware-brcm80211": ensure => "installed", allowcdrom = true }
#	package { "firmware-b43-lpphy-installer": ensure => "installed", require  => Exec['APT-Update'] , allowcdrom = true }
#	package { "broadcom-sta-dkms" : ensure => "installed", allowcdrom = true}
#	package { "firmware-realtek" : ensure => "installed", allowcdrom = true}
	package { "cowsay" : ensure => "installed", require => File['/etc'] }
	package { "flashplugin-nonfree" : ensure => "installed", require => File['/etc'] }
	package { "alsa-oss" : ensure => "installed", require => File['/etc']}
	package { "fbpanel" : ensure => "installed", require => Package['alsa-oss']}
	package { "cups" : ensure => "installed", require => File['/etc'] }
	package { "openssh-server" : ensure => "installed", require => File['/etc'] }
	package { "iptables-persistent" : ensure => "installed", require => File['/etc'] }
	package { "msttcorefonts" : ensure => "installed", allowcdrom => true }

	exec { "APT-Update":
                command => "/usr/bin/apt-get update",
                path    => "/bin/bash",
                # path    => [ "/usr/local/bin/", "/bin/" ],  # alternative syntax
        }
	
	service { "wicd":
		ensure	=> "running",
		enable	=> "true",
	}
	

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
		before 	=> exec["purge default firewall"]
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
}


