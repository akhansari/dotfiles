export module ./xgt.nu
export module ./xws.nu

export def ll [] { ls -a | sort-by type }

export def "http serve" [] {
    start http://localhost:8000
    python3 -m http.server
}
