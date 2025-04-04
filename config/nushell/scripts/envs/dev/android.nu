use std

export-env {

    load-env {
        ANDROID_SDK: ($env | get HOME | path join 'Android/Sdk')
    }

    std path add ($env | get  ANDROID_SDK | path join 'tools')
    std path add ($env | get  ANDROID_SDK | path join 'tools/bin')
    std path add ($env | get  ANDROID_SDK | path join 'platform-tools')
}