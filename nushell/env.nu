
$env.XDG_CONFIG_HOME = $env.HOME + "/.config"
$env.HOMEBREW_BUNDLE_FILE = $env.XDG_CONFIG_HOME + "/homebrew/Brewfile"
$env.PAGER = "ov -F"
$env.EDITOR = "nvim"
$env.CARAPACE_BRIDGES = "bash"

$env.PATH = ($env.PATH | split row (char esep) | prepend "/home/linuxbrew/.linuxbrew/bin/")
$env.PATH = ($env.PATH | split row (char esep) | prepend "/home/linuxbrew/.linuxbrew/sbin/")

$env.AWS_DEFAULT_REGION = "eu-west-1"
$env.AWS_DEFAULT_PROFILE = "guild-dev"
$env.AWS_PAGER = "batcat -l=yaml --style=plain"

$env.AVIV_GIT_ORG = "axel-springer-kugawana"
$env.AVIV_REPO_ARCHITECTURE = "~/git-aviv/arch/aviv_architecture"
$env.AVIV_REPO_AFT = "~/git-aviv/ops/aviv-aft-account-request"
$env.AVIV_REPO_WORKSPACES = "~/git-aviv/ops/aviv-foundation-workspace-config"
 
