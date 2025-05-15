# Forecasting App

## To Set up:
```RAILS_MASTER_KEY=<master_key_value from config/master.key> docker compose up --build```
App is available at http://localhost:3001

# To Develop locally:
1. Copy over the .env.sample file
```
cp .env.sample .env.development.local
cp .env.sample .env.test
```
2. You may run into permission issues with a dockerized postgres. For development and testing dbs only:
```
docker compose exec postgres /bin/bash
```
Once in shell
```
bash-5.1# psql -d forecast_app_test


