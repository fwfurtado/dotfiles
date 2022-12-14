module makefile {
    def 'complete with makefile targets' [] {
        if ("Makefile" | path exists) {
            let regex = '^(\w|%)((\w|\.|%|\\|\/|_|-)*\s?)*(:|&:)'
            open Makefile | lines | where ($it =~ $regex) | str replace '&' '' | each { |it| str substring 0..($it | str index-of ':') } | str trim | split row ' ' | flatten
        } else {
            []
        }
        
    }


    # Make
    export extern "make" [
        target?: string@"complete with makefile targets"
    ]
}

use makefile *