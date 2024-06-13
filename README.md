# No2Date API

API to store and retrieve confidential development files (configuration, credentials)

## Vulnerabilites
https://docs.google.com/document/d/1_DufdMLVxXIdT0sk0V0GbFlayJkandcalPLfxe_eugo/edit?usp=drive_link

## Routes

All routes return Json

- GET `/`: Root route shows if Web API is running
- GET `api/v1/appointments/[ID]`: Get information about a appointment
- GET `api/v1/appointments`: Get list of all appointments
- POST `api/v1/appointments`: Create new appointment
- GET `api/v1/appointments/[appt_id]/events/[evnt_id]`: Get a event
- GET `api/v1/appointments/[appt_id]/events`: Get list of events for appointment
- POST `api/v1/appointments/[ID]/events`: Create a event for a appointment (ID would be where the event should be saved in)

## google-apis-calendar_v3
- ref: https://rubygems.org/gems/google-apis-calendar_v3/versions/0.5.0?locale=zh-TW
- gem install google-apis-calendar_v3 -v 0.5.0

## Install

Install this API by cloning the *relevant branch* and installing required gems from `Gemfile.lock`:

```shell
bundle install
```
Setup development database once:

```shell
rake db:drop
```

```shell
rake db:migrate
```

```shell
puma
```
## Test

Drop DB and migrate again if database structure has been modified:

```shell
RACK_ENV=test rake db:drop
```

Setup test database once:

```shell
RACK_ENV=test rake db:migrate
```

Run the test specification script in `Rakefile`:

```shell
rake spec
```

```shell
# Run spec and audit tasks first before rubocop
rake style
```

```shell
# List all rake tasks
rake -T
```
## Develop/Debug

Add fake data to the development database to work on this project:

```shell
rake db:seed
```

## Execute

Launch the API using:

```shell
rake run:dev
```

```shell
rakeup
```

## Release check

Before submitting pull requests, please check if specs, style, and dependency audits pass (will need to be online to update dependency database):

```shell
# List all rake tasks
rake release?
```

##  Sequel DB POST / GET Usage

### Create a appointment
After running puma, open up a new local terminal and check up your local endpoint address. e.g. http://0.0.0.0:9292
Run the POST message with new information and your local endpoint address.
```shell
curl -X POST -H "Content-Type: application/json" -d '{
    "name": "Security appointments",
    "organizer": "Brian",
    "attendees": "Ella"
}' http://0.0.0.0:3000/api/v1/appointments
```
The id will be generated automatically in numerical order.
The empty columns will be noted as null.

The response message would be:

```shell
{
  "message": "appointment saved",
  "data":
  {
    "type": "appointment",
    "attributes":
    {
      "id": 1,
      "name": "Security appointments",
      "description": null,
      "organizer": "Brian",
      "attendees": "Ella"
    }
  }
}
```

### Get a appointment
Retrieve the details of a specific appointment by its id.
Run the GET message with the specific id and your local endpoint address.
```shell
curl -X GET http://0.0.0.0:3000/api/v1/appointments/[ID]
# or
curl http://0.0.0.0:3000/api/v1/appointments/[ID]
```
Or we can enter the GET message on browser's address bar (URL bar).
```shell
http://localhost:9292/api/v1/appointments/[ID]
```

The response message would be (for example):
```shell
{
  "type": "appointment",
  "attributes":
  {
    "id": 1,
    "name": "Security appointments",
    "description": null,
    "organizer": "Brian",
    "attendees": "Ella"
  }
}
```

### Listing all appointments
Retrieve all appointments' ids.
Run the GET message with your local endpoint address.
```shell
curl -X GET http://0.0.0.0:3000/api/v1/appointments
# or
curl http://0.0.0.0:3000/api/v1/appointments
```
Or we can enter the GET message on browser's address bar (URL bar).
```shell
http://localhost:3000/api/v1/appointments
```

The response message would be a list of evnt_ids:
```shell
{
  "data": [
    {
      "type": "appointment",
      "attributes":
      {
        "id": 1,
        "name": "Security appointments",
        "description": null,
        "organizer": "Brian",
        "attendees": "Ella"
      }
    },
    {
      "type": "appointment",
      "attributes":
      {
        "id": 2,
        "name": "Security appointments",
        "description": null,
        "organizer": "Brian",
        "attendees": "Ella"
      }
    }
  ]
}
```

### Create a event
After running puma, open up a new local terminal and check up your local endpoint address. e.g. http://0.0.0.0:9292
Run the POST message with new information and your local endpoint address.
You should assign the [uuid] to the specific ID to save your info to the specific appointment.

```shell
curl -X POST -H "Content-Type: application/json" -d '{
  "title": "Discussion for SOA project",
  "description": null,
  "location": "TSMC building, NTHU",
  "start_datetime": "2024-04-19 09:00:00 +0800",
  "end_datetime": "2024-04-19 10:00:00 +0800",
  "is_google": true,
  "is_flexible": false
}' http://0.0.0.0:3000/api/v1/events
```
The id will be generated automatically in numerical order.
The empty colomns will be noted as null.

The response message would be:
```shell
{
  "message": "event saved",
  "data":
  {
    "type": "event",
    "attributes":
    {
      "id": "152d30ff-1f63-49a0-b08e-425e45dbbbad",
      "title": "Discussion for SOA project",
      "description": null,
      "location": "TSMC building, NTHU",
      "start_datetime": "2024-04-19 09:00:00 +0800",
      "end_datetime": "2024-04-19 10:00:00 +0800",
      "is_google": true,
      "is_flexible": false
    }
  }
}
```
### Get a event
Retrieve the details of a specific event by its id.
Run the GET message with the specific id and your local endpoint address.
```shell
curl -X GET http://0.0.0.0:3000/api/v1/events/[uuid]
# or
curl http://0.0.0.0:3000/api/v1/events/[uuid]
```
Or we can enter the GET message on browser's address bar (URL bar).
```shell
http://localhost:3000/api/v1/events/[uuid]
```

The response message would be (for example):
```shell
{
  "type": "event",
  "attributes":
  {
    "id": "bbaf6b6c-d97b-4d3c-ad36-4a9531a8d8b5",
    "title": "Discussion for SOA project",
    "description": null,
    "location": "TSMC building, NTHU",
    "start_datetime": "2024-04-19 09:00:00 +0800",
    "end_datetime": "2024-04-19 10:00:00 +0800",
    "is_google": true,
    "is_flexible": false
  }
}
```

### Listing all events
Retrieve all events' ids.
Run the GET message with your local endpoint address.
```shell
curl -X GET http://0.0.0.0:3000/api/v1/events
# or
curl http://0.0.0.0:3000/api/v1/events
```
Or we can enter the GET message on browser's address bar (URL bar).
```shell
http://localhost:3000/api/v1/events
```

The response message would be a list of evnt_ids:
```shell
{
  "data": [
    {
      "type": "event",
      "attributes":
      {
        "id": "152d30ff-1f63-49a0-b08e-425e45dbbbad",
        "title": "Discussion for SOA project",
        "description": null,
        "location": "TSMC building, NTHU",
        "start_datetime": "2024-04-19 09:00:00 +0800",
        "end_datetime": "2024-04-19 10:00:00 +0800",
        "is_google": true,
        "is_flexible": false
      }
    },
    {
      "type": "event",
      "attributes":
      {
        "id": "bbaf6b6c-d97b-4d3c-ad36-4a9531a8d8b5",
        "title": "Discussion for SOA project",
        "description": null,
        "location": "TSMC building, NTHU",
        "start_datetime": "2024-04-19 09:00:00 +0800",
        "end_datetime": "2024-04-19 10:00:00 +0800",
        "is_google": true,
        "is_flexible": false
      }
    }
  ]
}
```

### Create a account
After running puma, open up a new local terminal and check up your local endpoint address. e.g. http://0.0.0.0:3000
Run the POST message with new information and your local endpoint address.

```shell
curl -X POST -H "Content-Type: application/json" -d '{
  "username": "brian",
  "email": "brian@nthu.edu.tw",
  "password": "mypa$$w0rda"
}' http://0.0.0.0:3000/api/v1/accounts

curl -X POST -H "Content-Type: application/json" -d '{
  "username": "ella",
  "email": "ella@nthu.edu.tw",
  "password": "123"
}' http://0.0.0.0:3000/api/v1/accounts
```
The id will be generated automatically in numerical order.
The empty colomns will be noted as null.

The response message would be:
```shell
{
  "message":"Account saved",
  "data":
  {
    "type":"account",
    "attributes":
    {
      "username":"brian",
      "email":"brian@nthu.edu.tw"
    }
  }
}
```
### Get an account
Retrieve the details of a specific account by its username.
Run the GET message with the specific usernam and your local endpoint address.
```shell
curl -X GET http://0.0.0.0:3000/api/v1/accounts/[username]
# or
curl http://0.0.0.0:3000/api/v1/accounts/[username]
```
Or we can enter the GET message on browser's address bar (URL bar).
```shell
http://localhost:3000/api/v1/accounts/[username]
```

The response message would be (for example):
```shell
{
  "type": "account",
  "attributes":
  {
    "username": "brian",
    "email": "brian@nthu.edu.tw"
  }
}
```