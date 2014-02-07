class osx-base {
	file { "geektool system info":
		path 	=> '/System/Library/User Template/English.lproj/Library/Preferences/org.tynsoe.geeklet.shell.plist',
		ensure 	=> present,
		owner	=> "root",
		group	=> "wheel",
		mode 	=> 0777,
		source  => "puppet:///modules/osx-base/geektool/org.tynsoe.geeklet.shell.plist",
	}

	file {"test":
		path	=> '/Users/administrator/Desktop/Hello.txt',
		ensure 	=> present,
		owner	=> "administrator",
		group	=> "wheel",
		mode	=> 0777,
		content	=> "Hello World",
	}

	exec {"Set setting":
		command => "defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText 'PSD OSX Build 1.0'",
		path    => "/bin/bash",
		# path    => [ "/usr/local/bin/", "/bin/" ],  # alternative syntax
	}
}


