
export def activity [] {
    git log --pretty=%aN | lines | histogram
}

export def commits [number: int = 25] {
    git log --pretty=%h»¦«%s»¦«%aN»¦«%aD -n $number
    | lines
    | split column "»¦«" commit message name date
    | upsert date {|d| $d.date | into datetime}
}

export def del-other-branches [] {
    git branch
    | lines
    | find "*" --invert
    | each {|b| git branch -D ($b | str trim) }
}

export def branches [] {
    git for-each-ref --format="%(objecttype)|%(authorname)|%(refname)|%(committerdate:iso-strict)"
    | lines
    | split column "|" type author name date 
    | where not ($it.name | str starts-with "refs/tags/")
    | upsert date {|d| $d.date | into datetime }
    | select author name date
    | sort-by date -r
}
