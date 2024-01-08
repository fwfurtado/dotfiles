export-env {
    $env.config = ($env.config | upsert hooks {
      env_change: {
          PWD: ($env.config.hooks.env_change.PWD ++
          [{
          condition: {|| not (which direnv | is-empty)}
          code: {|| direnv export json | from json | default {} | load-env }
          }])
      }
  })
}