
def contains [value: string] {
    $in != null and ($in | str contains -i $value)
}

def first-if-one [] {
    if ($in | length) == 1 {
        $in | first
    } else {
        $in
    }
}

def ll [] { ls -a | sort-by type }

def git-activity [] {
    git log --pretty=%aN | lines | histogram
}

def git-commits [number: int = 25] {
    git log --pretty=%h»¦«%s»¦«%aN»¦«%aD -n $number
    | lines
    | split column "»¦«" commit message name date
    | upsert date {|d| $d.date | into datetime}
}

def git-del-other-branches [] {
    git branch
    | lines
    | find "*" --invert
    | each {|b| git branch -D ($b | str trim) }
}

def lambda-invoke [name: string, --body (-b)] {
    aws lambda invoke --function-name $name /dev/stdout
    | parse --regex '({.*})'
    | get 0.capture0
    | from json
    | if $body { get body | from json } else { $in }
}

def lambda-list [--full (-f)] {
    aws lambda list-functions
    | from yaml
    | get Functions
    | find -i -v -c [ FunctionName ] custodian
    | upsert LastModified {|d| $d.LastModified  | into datetime}
    | if $full { $in } else { select FunctionName LastModified }
    | sort-by LastModified
    | reverse
}

def lambda-get [name?: string] {
    if $name == null {
        let $name = lambda-list | get FunctionName | to text | fzf
        aws lambda get-function --function-name $name | from yaml
    } else {
        let $names = lambda-list
            | get FunctionName
            | where ($it | contains $name)
        if ($names | is-empty) {
            print "Not found"
        } else {
            let $fullname = $names | first
            aws lambda get-function --function-name $fullname | from yaml
        }
    }
}

def aws-assume-role [] {
    let $arn = aws sts get-caller-identity --query Arn --output text
    let $role_arn = aws iam list-roles --query $"Roles[?AssumeRolePolicyDocument.Statement[?Effect=='Allow'&&Principal.AWS=='($arn)']].Arn" --output text | fzf
    aws sts assume-role --role-arn $role_arn --role-session-name "localhost"
}
