# No2Date API

API to store and retrieve confidential development files (configuration, credentials)

## Vulnerabilites
https://docs.google.com/document/d/1_DufdMLVxXIdT0sk0V0GbFlayJkandcalPLfxe_eugo/edit?usp=drive_link

## Routes

All routes return Json

- GET `/`: Root route shows if Web API is running
- GET `api/v1/meetings/[ID]`: Get information about a meeting
- GET `api/v1/meetings`: Get list of all meetings
- POST `api/v1/meetings`: Create new meeting
- GET `api/v1/meetings/[meet_id]/schedules/[sched_id]`: Get a schedule
- GET `api/v1/meetings/[meet_id]/schedules`: Get list of schedules for meeting
- POST `api/v1/meetings/[ID]/schedules`: Create a schedule for a meeting (ID would be where the schedule should be saved in)

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
rake db:migrate
```

## Execute

Run this API using:

```shell
puma
```

## Test

Setup test database once:

```shell
RACK_ENV=test rake db:migrate
```

Drop DB and migrate again if database structre has been modified:

```shell
RACK_ENV=test rake db:drop
```

Run the test specification script in `Rakefile`:

```shell
rake spec
```

Run the test script:

```shell
rake api_spec
```

```shell
# Run all spec
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
## Release check

Before submitting pull requests, please check if specs, style, and dependency audits pass:

```shell
# List all rake tasks
rake release?
```

##  Sequel DB POST / GET Usage

### Create a meeting
After running puma, open up a new local terminal and check up your local endpoint address. e.g. http://0.0.0.0:9292
Run the POST message with new information and your local endpoint address.
```shell
curl -X POST -H "Content-Type: application/json" -d '{
    "name": "Security meetings",
    "organizer": "Brian",
    "attendees": "Ella"
}' http://0.0.0.0:9292/api/v1/meetings
```
The id will be generated automatically in numerical order.
The empty colomns will be noted as null.

The response message would be:
```shell
{
  "message": "Meeting saved",
  "data":
  {
    "data":
    {
      "type": "meeting",
      "attributes":
      {
        "id": 2,
        "name": "Security meetings",
        "description": null,
        "organizer": "Brian",
        "attendees": "Ella"
      }
    }
  }
}
```
### Get a meeting
Retrieve the details of a specific meeting by its id.
Run the GET message with the specific id and your local endpoint address.
```shell
curl -X GET http://0.0.0.0:9292/api/v1/meetings/[ID]
# or
curl http://0.0.0.0:9292/api/v1/meetings/[ID]
```
Or we can enter the GET message on browser's address bar (URL bar).
```shell
http://localhost:9292/api/v1/meetings/[ID]
```

The response message would be (for example):
```shell
{
  "data":
    {
      "type": "meeting",
      "attributes":
        {
          "id": 1,
          "name": "Security meetings",
          "description": null,
          "organizer": "Brian",
          "attendees": "Ella"
        }
    }
}
```

### Listing all meetings
Retrieve all meetings' ids.
Run the GET message with your local endpoint address.
```shell
curl -X GET http://0.0.0.0:9292/api/v1/meetings
# or
curl http://0.0.0.0:9292/api/v1/meetings
```
Or we can enter the GET message on browser's address bar (URL bar).
```shell
http://localhost:9292/api/v1/meetings
```

The response message would be a list of sched_ids:
```shell
{
  "data": [
    {
      "data":
        {
        "type": "meeting",
          "attributes":
          {
            "id": 1,
            "name": "Security meetings",
            "description": null,
            "organizer": "Brian",
            "attendees": "Ella"
          }
        }
    },
    {
      "data":
        {
          "type": "meeting",
          "attributes":
          {
            "id": 2,
            "name": "Security meetings",
            "description": null,
            "organizer": "Brian",
            "attendees": "Ella"
          }
      }
    }
  ]
}
```

### Create a schedule
After running puma, open up a new local terminal and check up your local endpoint address. e.g. http://0.0.0.0:9292
Run the POST message with new information and your local endpoint address.
You should assign the [ID] to the specific ID to save your info to the specific meeting.

```shell
curl -X POST -H "Content-Type: application/json" -d '{
  "title": "Discussion for SOA project",
  "description": null,
  "location": "TSMC building, NTHU",
  "start_date": "2024-04-19",
  "start_datetime": "2024-04-19 09:00:00 +0800",
  "end_date": "2024-04-19",
  "end_datetime": "2024-04-19 10:00:00 +0800",
  "is_regular": true,
  "is_flexible": false
}' http://0.0.0.0:9292/api/v1/meetings/[ID]/schedules
```
The id will be generated automatically in numerical order.
The empty colomns will be noted as null.

The response message would be:
```shell
{
  "message": "Schedule saved",
  "data":
    {
      "data":
      {
        "type": "schedule",
        "attributes":
        {
          "id": 3,
          "title": "Discussion for SOA project",
          "description": null,
          "location": "TSMC building, NTHU",
          "start_date": "2024-04-19",
          "start_datetime": "2024-04-19 09:00:00 +0800",
          "end_date": "2024-04-19",
          "end_datetime": "2024-04-19 10:00:00 +0800",
          "is_regular": true,
          "is_flexible": false
        }
      },
      "included":
        {
        "meeting":
          {
          "data":
            {
              "type": "meeting",
              "attributes":
                {
                  "id": 1,
                  "name": "Security meetings",
                  "description": null,
                  "organizer": "Brian",
                  "attendees": "Ella"
                }
            }
          }
        }
    }
}
```
### Get a schedule
Retrieve the details of a specific schedule by its id.
Run the GET message with the specific id and your local endpoint address.
```shell
curl -X GET http://0.0.0.0:9292/api/v1/meetings/[ID]/schedules/[ID]
# or
curl http://0.0.0.0:9292/api/v1/meetings/[ID]/schedules/[ID]
```
Or we can enter the GET message on browser's address bar (URL bar).
```shell
http://localhost:9292/api/v1/meetings/[ID]/schedules/[ID]
```

The response message would be (for example):
```shell
# http://localhost:9292/api/v1/meetings/1/schedules/1
{
  "data":
    {
      "type": "schedule",
      "attributes":
        {
          "id": 1,
          "title": "Discussion for SEC project",
          "description": null,
          "location": "TSMC building, NTHU",
          "start_date": "2024-04-19",
          "start_datetime": "2024-04-19 09:00:00 +0800",
          "end_date": "2024-04-19",
          "end_datetime": "2024-04-19 10:00:00 +0800",
          "is_regular": null,
          "is_flexible": null
        }
    },
  "included":
    {
      "meeting":
        {
          "data":
            {
              "type": "meeting",
              "attributes":
                {
                  "id": 1,
                  "name": "Security meetings",
                  "description": null,
                  "organizer": "Brian",
                  "attendees": "Ella"
                }
            }
        }
    }
}
```

### Listing all schedules
Retrieve all schedules' ids.
Run the GET message with your local endpoint address.
```shell
curl -X GET http://0.0.0.0:9292/api/v1/meetings/[ID]/schedules/
# or
curl http://0.0.0.0:9292/api/v1/meetings/[ID]/schedules/
```
Or we can enter the GET message on browser's address bar (URL bar).
```shell
http://localhost:9292/api/v1/meetings/[ID]/schedules/
```

The response message would be a list of sched_ids:
```shell
# http://0.0.0.0:9292/api/v1/meetings/1/schedules
{
  "data": [
    {
      "data":
        {
          "type": "schedule",
          "attributes":
            {
              "id": 1,
              "title": "Discussion for SEC project",
              "description": null,
              "location": "TSMC building, NTHU",
              "start_date": "2024-04-19",
              "start_datetime": "2024-04-19 09:00:00 +0800",
              "end_date": "2024-04-19",
              "end_datetime": "2024-04-19 10:00:00 +0800",
              "is_regular": null,
              "is_flexible": null
            }
        },
      "included":
        {
          "meeting":
            {
              "data":
                {
                  "type": "meeting",
                  "attributes":
                    {
                      "id": 1,
                      "name": "Security meetings",
                      "description": null,
                      "organizer": "Brian",
                      "attendees": "Ella"
                    }
                }
            }
        }
    },
    {
      "data":
        {
          "type": "schedule",
          "attributes":
            {
              "id": 2,
              "title": "Discussion for SOA project",
              "description": null,
              "location": "TSMC building, NTHU",
              "start_date": "2024-04-20",
              "start_datetime": "2024-04-19 09:00:00 +0800",
              "end_date": "2024-04-20",
              "end_datetime": "2024-04-19 10:00:00 +0800",
              "is_regular": true,
              "is_flexible": false
            }
        },
      "included":
        {
          "meeting":
            {
              "data":
                {
                  "type": "meeting",
                  "attributes":
                    {
                      "id": 1,
                      "name": "Security meetings",
                      "description": null,
                      "organizer": "Brian",
                      "attendees": "Ella"
                    }
                }
            }
        }
    }
  ]
}
```