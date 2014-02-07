node 'des-library' {
	$bookmarks = [
		{name => "PSD Portal", url => "http://my.psd401.net"},
		{name => "Renaissance Place", url => "https://hosted94.renlearn.com/296531/"},
		{name => "Destiny", url	=> "http://library.psd401.net/district/servlet/presentlistsitesform.do;jsessionid=A1F7CEC67C31D2FB7A1CA83F4ABD5720?districtMode=true"}
	]
	include base
}

node /brandon/, /601111/, /601263/, /303045/ inherits 'des-library' {
	
}



node /web/, /dtmes503588/ {
	$bookmarks = [ 
        	{name => "PSD Portal", url => "http://my.psd401.net"}, 
        	{name => "Staff Email", url => "http://email.psd401.net"}, 
	]
	include base
}

node /m10/ {
	include osx-base
}

node default {
}

node /testing/ {
	include development
	$bookmarks = [
                {name => "PSD Portal", url => "http://my.psd401.net"},
                {name => "Renaissance Place", url => "https://hosted94.renlearn.com/296531/"},
                {name => "Destiny", url => "http://library.psd401.net/district/servlet/presentlistsitesform.do;jsessionid=A1F7CEC67C31D2FB7A1CA83F4ABD5720?districtMode=true"}
        ]

}



