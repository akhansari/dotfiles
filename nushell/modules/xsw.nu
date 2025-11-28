
export def --env set-envs [] {
    let access = scw config get access-key
    let secret = scw config get secret-key
    # $env.SCW_ACCESS_KEY = $access
    # $env.SCW_SECRET_KEY = $secret
    $env.AWS_ACCESS_KEY_ID = $access
    $env.AWS_SECRET_ACCESS_KEY = $secret
}
