use abbr.nu

export def main [
    --verbose(-v)
] {
  let input = (^lsof +c 0xFFFF -i -n -P)
  let header = ($input | lines
                       | take 1
                       | each { str downcase | str replace ' name$' ' name state' })
  let body = ($input | lines
                     | skip 1
                     | each { str replace '([^)])$' '$1 (NONE)' | str replace ' \((.+)\)$' ' $1' })
  let result = [$header] | append $body
                    | to text
                    | detect columns
                    | upsert 'pid' { |r| $r.pid | into int }
                    | rename --column { name: connection }
                    | reject 'command'
    if ($verbose) {
      $result
      | join (ps -l | reject command) pid
      | upsert 'name' { |r| $r.name | abbr home }
    } else {
      $result
    }
}
