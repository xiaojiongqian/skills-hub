# Smoke Test

## Environment
- name: local-dev
- base_url: http://localhost:3000
- verify: landing page shows the TaleDraw creator shell
- prerequisites: dev server is running

## Accounts
### Account: Creator smoke
- role: creator
- auth: existing session cookie or direct login
- handoff: none

## Suite: Creator critical path
- default_account: Creator smoke

### Case: Open landing page
- route: /
- steps:
  - open the page
- expect: landing page is visible

### Case: Primary create case
- route: /create
- steps:
  - perform the main create action
- expect: success state appears
