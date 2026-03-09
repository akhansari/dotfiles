
$env.PATH = $env.PATH | prepend "/home/linuxbrew/.linuxbrew/sbin/"
$env.PATH = $env.PATH | prepend "/home/linuxbrew/.linuxbrew/bin/"
$env.PATH = $env.PATH | prepend "/home/linuxbrew/.linuxbrew/opt/libpq/bin/"

$env.PAGER = "ov -F"
$env.BAT_PAGER = "ov -F -H3"
$env.EDITOR = "nvim"
$env.SUDO_EDITOR = "nvim"
$env.CARAPACE_BRIDGES = "bash"
$env.SSH_AUTH_SOCK = $env.XDG_RUNTIME_DIR + "/ssh-agent.socket"
