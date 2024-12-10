
export def git-activity [] {
    git log --pretty=%aN | lines | histogram
}

export def git-commits [number: int = 25] {
    git log --pretty=%h»¦«%s»¦«%aN»¦«%aD -n $number
    | lines
    | split column "»¦«" commit message name date
    | upsert date {|d| $d.date | into datetime}
}

export def git-del-other-branches [] {
    git branch
    | lines
    | find "*" --invert
    | each {|b| git branch -D ($b | str trim) }
}

