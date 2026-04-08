export def negate [...value: bool] bool -> bool {
    let input = if ($value | is-empty) { $in } else { $value }
    $input | each {|it| not $it}
 }
export def "is-not-empty" [] { is-empty | negate }

export def is-null [...value: any]: any -> bool {
    let input = if ($value | is-empty) { $in } else { $value }
    $input | each {|it|  ($it | describe) == "nothing"}
}

export def is-not-null [...value: any]: any -> bool {
    let input = if ($value | is-empty) { $in } else { $value }
    $input | is-null | each {|it| not $it}
}


#[test]
def should_rename_stem [] {
    use std assert
    use random-list.nu *

    let values = (random-list bool 100)

    let actual = $values | negate

    assert not equal $actual $values

    actual = $values | negate

    assert equal $actual $values

}