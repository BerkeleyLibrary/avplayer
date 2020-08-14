#!/usr/bin/env groovy

dockerComposePipeline(
  commands: [
    'rake coverage',
    'rake rubocop',
    'rake brakeman',
    'rake bundle:audit'
  ],
  artifacts: [
    junit   : 'artifacts/rspec/**/*.xml',
    html    : [
      'Code Coverage': 'artifacts/rcov',
      'RuboCop'      : 'artifacts/rubocop',
      'Brakeman'     : 'artifacts/brakeman'
    ]
  ]
)
