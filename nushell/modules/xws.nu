use helpers.nu *

export def lambda-list [--full (-f)] {
    aws lambda list-functions
    | from yaml
    | get Functions
    | find -i -v -c [ FunctionName ] custodian
    | upsert LastModified {|d| $d.LastModified  | into datetime}
    | if $full { $in } else { select FunctionName LastModified }
    | sort-by LastModified
    | reverse
}

export def lambda-get [name?: string] {
    if $name == null {
        let $name = lambda-list | get FunctionName | to text | fzf --height=~15
        aws lambda get-function --function-name $name | from yaml
    } else {
        let $names = lambda-list
            | get FunctionName
            | where ($it | contains $name)
        if ($names | is-empty) {
            print -e "Lambda not found"
        } else {
            let $fullname = $names | first
            aws lambda get-function --function-name $fullname | from yaml
        }
    }
}

export def lambda-invoke [name: string, --body (-b)] {
    aws lambda invoke --function-name $name /dev/stdout
    | parse --regex '({.*})'
    | get 0.capture0
    | from json
    | if $body { get body | from json } else { $in }
}

export def apigw-invoke [] {
    let $apigw = aws apigateway get-rest-apis | from yaml | get items | select id name | input list --display name
    let $resource = aws apigateway get-resources --rest-api-id $apigw.id | from yaml | get items | input list --display path
    let $method = $resource.resourceMethods | columns | input list
    aws apigateway test-invoke-method --rest-api-id $apigw.id --resource-id $resource.id --http-method $method | from yaml
}

export def --env aws-assume-role [] {
    let $arn = aws sts get-caller-identity | from yaml | get Arn
    let $roles = aws iam list-roles
        | from yaml
        | get Roles
        | each {|x| {Arn:$x.Arn, AssumedRoles: ($x.AssumeRolePolicyDocument.Statement.Principal.AWS? | flatten)} }
        | filter {|x| $x.AssumedRoles | all {|| $in == $arn } }
    if ($roles | is-empty) {
        print -e "Role not found"
        return
    }
    let $assumed = aws sts assume-role --role-arn $roles.0.Arn --role-session-name "localhost" | from yaml
    $env.API_IAM_ACCESS_KEY_ID = $assumed.Credentials.AccessKeyId
    $env.API_IAM_SECRET_ACCESS_KEY = $assumed.Credentials.SecretAccessKey
    $env.API_IAM_SESSION_TOKEN = $assumed.Credentials.SessionToken
    $assumed
}

