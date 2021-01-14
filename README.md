# Docker images for building and testing PHP (Laravel) applications via Cypress with Gitlab CI

`.gitlab-ci.yml` example

```bash
stages:
    - test

cypress:
    stage: test
    image: technerve/laravel-cypress-ci:0.0.6
    only:
        - develop
    services:
        - name: mysql:5.7
          alias: mysql
    script:
        - cp .env.example .env
        - php artisan key:generate
        - npm install
        - php artisan serve &
        - npx cypress install
        - xvfb-run npx cypress verify
        - xvfb-run npx cypress run --config baseUrl=http://localhost:8000,video=false
```