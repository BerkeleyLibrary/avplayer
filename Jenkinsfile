#!/usr/bin/env groovy

dockerComposePipeline(
  commands: [
    'rake coverage RAILS_ENV=test',
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
