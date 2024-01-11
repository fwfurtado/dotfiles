export def negate [] -> bool {
    each {|it|
        try {
            not $it
        } catch {
            true
        }
    }
 }
export def "is-not-empty" [] { is-empty | negate }