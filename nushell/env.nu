
$env.PAGER = "ov -F"
$env.EDITOR = "nvim"
$env.CARAPACE_BRIDGES = "bash"
$env.PNPM_HOME = "/home/akhansari/.local/share/pnpm"

$env.PATH = ($env.PATH | split row (char esep) | prepend '/home/linuxbrew/.linuxbrew/bin/')
$env.PATH = ($env.PATH | split row (char esep) | prepend '/home/linuxbrew/.linuxbrew/sbin/')
$env.PATH = ($env.PATH | split row (char esep) | append '/home/akhansari/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin')
$env.PATH = ($env.PATH | split row (char esep) | append $env.PNPM_HOME )

$env.AWS_DEFAULT_REGION = "eu-west-1"
$env.AWS_DEFAULT_PROFILE = "guild-dev"
$env.AWS_PAGER = "batcat -l=yaml --style=plain"

$env.AVIV_GIT_ORG = "axel-springer-kugawana"
$env.AVIV_REPO_ARCHITECTURE = "~/git-aviv/arch/aviv_architecture"
$env.AVIV_REPO_AFT = "~/git-aviv/ops/aviv-aft-account-request"
$env.AVIV_REPO_WORKSPACES = "~/git-aviv/ops/aviv-foundation-workspace-config"

