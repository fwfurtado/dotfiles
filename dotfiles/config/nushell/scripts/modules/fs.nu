use nullability.nu *

def "nu-completion fs component" [] {
    [
        {value: "filename"  , description: "The filename of given path"},
        {value: "name"      , description: "Alias for filename"},
        {value: "extension" , description: "The extension of given path"},
        {value: "ext"       , description: "Alias for extension"},
    ]
}

def "resolve component" [component: string@"nu-completion fs component"] {
    let path_components = {
        filename:   steam,
        name:       steam,
        ext:        extension,
        extension:  extension,
    }

    $path_components | get $component
}
# rename a bulk of files in a directory using a closure
#
# the reason behind this command is quite simple
# - sometimes one receives a bunch of files with integer ids: 1, 2, 3, ...
# - these ids come rarely with padding... i.e. 1 instead of 001 when there are 3-digit ids
# - this means that file with id 9 will be sorted way after file with id 1000
#
# this command allows to do such a task!
#
# # Examples
#     rename files in `/foo` with a name that has an id to have 3 digits with 0-padding
#     > file bulk-rename /foo {
#          parse "some_format_{id}"
#              | get 0
#              | update id { fill --alignment r --character 0 --width 3 }
#              | $"some_format_($in.id)"
#      }
export def "file bulk-rename" [
    directory: path, # the path where files need to be renamed in bulk
    component: string@"nu-completion fs component" # the component to use for completion
    fixed?: string, # the value to use for the update
    --block(-b): closure, # the code to run on the path component of the files
    --verbose, # be verbose when moving the files around
    --dry-run (-n) # do not actually move the files around
]: nothing -> nothing {
    let path_component = resolve component $component

    if ($path_component | is-empty) {
        error "unknown component: $component"
    }

    if ([$block $fixed] | all {|it| $it | is-null }) {
        error "either a block or a fixed value must be provided"
    }

    if ([$block $fixed] | all {|it| $it | is-not-null }) {
        error "either a block or a fixed value must be provided"
    }

    let update = if ($fixed | is-empty) {
        $block
    } else {
        { |$it| $fixed }
    }

    let rename_action = ls --full-paths $directory
        | insert after {|$it| $it
        | get name
        | path parse
        | update $path_component {|$it| $it | get $path_component | do $update }
        | path join
        }
    | rename --column {name: before}
    | select before after

    if $dry_run {
        print $rename_action
    } else {
        $rename_action | each {
            if $verbose {
                mv --force --verbose $in.before $in.after
            } else {
                mv --force $in.before $in.after
            }
        }
    }


    null
}

#[test]
def should_rename_stem [] {
    use std assert

    let test_dir = $nu.temp-path | path join (random uuid)

    mkdir $test_dir
    seq 1 10 | each {|i| touch ($test_dir | path join $"some_($i)_format.txt") }

    let expected = [
        "some_10_format.txt",
        "some_1_format.txt",
        "some_2_format.txt",
        "some_3_format.txt",
        "some_4_format.txt",
        "some_5_format.txt",
        "some_6_format.txt",
        "some_7_format.txt",
        "some_8_format.txt",
        "some_9_format.txt",
    ]
    let actual = glob $"($test_dir)/*" | str replace $test_dir "" | str trim --left --char "/"
    assert equal ($actual | sort) $expected

    file bulk-rename $test_dir stem --block {
        parse "some_{i}_format"
            | get 0
            | update i { fill --alignment r --character 0 --width 3 }
            | $"some_($in.i)_format"
    }

    let expected = [
        "some_001_format.txt",
        "some_002_format.txt",
        "some_003_format.txt",
        "some_004_format.txt",
        "some_005_format.txt",
        "some_006_format.txt",
        "some_007_format.txt",
        "some_008_format.txt",
        "some_009_format.txt",
        "some_010_format.txt",
    ]
    let actual = glob $"($test_dir)/*" | str replace $test_dir "" | str trim --left --char "/"
    assert equal ($actual | sort) $expected

    rm -rf $test_dir
}