export def "home" [] {
    $in | str replace $env.HOME '~'
}