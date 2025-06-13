export module ./xgt.nu
export module ./xws.nu

export def ll [] { ls -a | sort-by type }

export def "http serve" [] {
    start http://localhost:8000
    python3 -m http.server
}

export def --env y [...args] {
	let tmp = (mktemp -t "yazi-cwd.XXXXXX")
	yazi ...$args --cwd-file $tmp
	let cwd = (open $tmp)
	if $cwd != "" and $cwd != $env.PWD {
		cd $cwd
	}
	rm -fp $tmp
}
