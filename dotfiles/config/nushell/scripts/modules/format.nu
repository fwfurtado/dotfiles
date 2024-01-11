# Convert from contents of /proc/cpuinfo to structured data
export def "from cpuinfo" [] {
    lines
    | split list ''
    | each {
        split column ':'
        | str trim
        | update column1 {
            get column1
            | str replace -a ' ' '_'
        }
        | transpose -r -d
        | update flags {
            get flags
            | split row ' '
        }
        | update bugs {
            get bugs
            | split row ' '
        }
    }
}

# converts records into .ini files
export def "to ini" [] {
  transpose key value
  | update value {|row|
    $row.value
    | transpose key value
    | format '{key}={value}'
    | prepend $"[($row.key)]"
    | str join (char nl)
  }
  | get value
  | str join (char nl)
}

