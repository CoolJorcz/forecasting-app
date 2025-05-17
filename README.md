# Forecasting App

See the current forecast for your location

## Dependencies
- Rails 8.2
- Ruby 3.3.5
- Postgres 14.2
- Redis

## To Set up:
1. Copy over the .env.sample file (Flashpaper for api keys provided in email / contact andrew.jorczak@gmail.com if expired)
```
cp env.sample .env.development.local
cp env.sample .env.test
cp env.sample .env
```
2. Run the app
```RAILS_MASTER_KEY=<master_key_value from config/master.key> docker compose --env-file ./.env.development.local up --build```
App is available at http://localhost:3001
### NOTE: App needs to have proper http to https CSRF concerns resolved. A workaround is to set  `config.action_controller.forgery_protection_origin_check = false` in the environment config. For the purposes of this exercise, I configured as such but I'd be hesitant to actually do this in production without further research.

## To Develop and run locally:
1. Copy over the .env.sample file (Flashpaper for api keys provided in email / contact andrew.jorczak@gmail.com if expired)
```
cp env.sample .env.development.local
cp env.sample .env.test
```
2. You may run into permission issues with a dockerized postgres. For development and testing dbs only:
```
docker compose exec postgres /bin/bash
```
Once in shell
```
bash-5.1# psql -U admin -d forecasting_app_development
psql (14.2)
Type "help" for help.

forecasting_app_development=# CREATE ROLE $USER WITH SUPERUSER PASSWORD 'password'
```

3. Create dbs and migrations
```
$ bundle exec rails db:create
$ bundle exec rails db:migrate
$ bundle exec rails db:test:prepare
```
4. Launch server: `bundle exec rails s`
5. Run tests: `bundle exec rspec spec`
6. YARD docs: `yard server`

## Development Thoughts

My approach to developing this application was to use a standard server-side rendered template that would have a form for address input,
verify the address to ensure that it was a valid zip code for the provided primary line, and get the current forecast for the location. At first, I thought it wouldn't be necessary to use Postgres (only having one table) but I decided that the active_record validations for Addresses was a necessity for this application, plus on further thought using active job queueing is a good design pattern for interacting with 3rd party APIs / dealing with transient HTTP errors. I dockerized the application for ease of setup and to have redis and postgres in one place, although as things go with Docker, it's never quite that simple, especially with environment variables, roles/permissions, etc.
Challenging bits were transient Rails errors related to turbo streams (my main experience has been backed API development, and it has been a long time since I've used server-side rendering, but I felt a single page app a la Vue or React.js was overkill for this application) and permission issues within Docker (I'm a glutton for punishment). Error handling is somewhat in place, but there's still some issues with turbostreams responding correctly. 

As of this writing, the number one thing preventing scalability and productionizing for many users is this Christmas Lights antipattern I put in place to get a functional test working. The 3rd party API calls need to be extracted to a job queueing system: I'll probably experiment with ActiveJob, but in production depending on provider could move to SQS, and if I really want durability, something like Temporal workflows. Additionally, I'm not sold on the Address naming convention - probably would move it to ForecastAddress as if this application grows, address is too generic. And I'd like to version the controller for future API needs.

All in all, I very much enjoyed this exercise.

### TODOs:
* Set up ActiveJob queueing and extract 3rd party API calls
* More robust error handling on form actions
* Version Controller actions and extract into API modules
* Use Forecast API to get additional forecasts on a daily basis
* Improve UI
* Add CI/CD
* Add NGINX proxy 
* Provide a production instance on Heroku or AWS

