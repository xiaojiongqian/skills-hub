# Smoke

base_url: http://localhost:3000

## Pre
- user is logged in

## Flow: Primary create flow
- go to /create
- perform the main create action
- expect the success state appears

## Flow: Primary publish flow
- go to /items
- open the latest draft
- perform the publish action
- expect status shows Published
