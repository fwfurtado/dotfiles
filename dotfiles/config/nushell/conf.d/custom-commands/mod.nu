export def negate [] { do {|| not $in} }
export def "is-not-empty" [] { is-empty | negate }