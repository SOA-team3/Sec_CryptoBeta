# Calender API

API to store and retrieve confidential development files (configuration, credentials)

## Routes

All routes return Json

- GET `/`: Root route shows if Web API is running
- GET `api/v1/calenders/`: returns all confiugration IDs
- GET `api/v1/calenders/[ID]`: returns details about a single calenders with given ID
- POST `api/v1/calenders/`: creates a new calenders

## google-apis-calendar_v3
- ref: https://rubygems.org/gems/google-apis-calendar_v3/versions/0.5.0?locale=zh-TW
- gem install google-apis-calendar_v3 -v 0.5.0

## Install

Install this API by cloning the *relevant branch* and installing required gems from `Gemfile.lock`:

```shell
bundle install
```

## Test

Run the test script:

```shell
ruby spec/api_spec.rb
```

## Execute

Run this API using:

```shell
puma
```
