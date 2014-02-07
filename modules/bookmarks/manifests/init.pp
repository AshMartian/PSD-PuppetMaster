class bookmarks {
	file {"/etc":
		ensure	=> directory,
		recurse	=> true,
		source 	=> 'puppet:///modules/bookmarks/etc',
	}
}


