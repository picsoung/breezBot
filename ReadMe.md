# Breezometer Slack Bot

Get Air quality directly in Slack. Using [Breezometer](http://breezometer.com) data.

# How-to
Command to post in a Slack channel

`breez CITY_NAME`

### examples
`breez San Francisco`

result

![Screenshot Air quality for San Francisco](https://i.imgur.com/WXS3PgB.png)

It gives you the air quality level and recommendations.

- :hatching_chick: for kids
- :heart: for health
- :house: for indoor
- :tent: for outdoor
- :soccer: for sport

Failed request for a city not supported `breez Barcelona`

![Request for a city that's is not supported](https://i.imgur.com/b0Jgtjp.png)

## Installation guide

### Pre-requisite
  - Breezometer API account, [create one](http://breezometer.com/developers-api/)
  - Slack organization, [create one](https://slack.com/)
  - APItools account, [create one](https://apitools.com)
  - Time :)
 
### Slack part
#### 1. Create outgoing webhook
Outgoing webhook is used to "listen" what's happening on channels.
To create a new one go on `https://YOUR_ORG.slack.com/services/new`

On the next page you will select on which channel of your organization you want to bot to be active. And the triggered words. Triggered words are the words that will make the bot react. In our case *breez*.

At the bottom of the page you can give a cute name to your bot as well as an avatar.
We will come back later to this page to fill the other fields.

#### 2. Create incoming webhook
Incoming webhook is used to send data to channels.
Again we go on `https://YOUR_ORG.slack.com/services/new`
And create an `incoming webhook`.

Define on which channel you want to post, change the name of the bot and it's icon. All these could be overide later.

Keep the `Webhook URL` somewhere we will need it later to send a `POST` request and send data to slack.

### APItools
Using APItools is a great way to avoid maintaining servers for something as simple as webhooks. It's also free to use.

#### Breezometer API
Create a new service with the *API URL* `http://api-beta.breezometer.com/baqi/`
This service will be used to make all the requests to Breezometer API.

We don't have any middleware code for this service.

#### Handling webhook
Anytime our triggered word is used in a channel, slack will make a request to an URL. We want to URL to be an API service. This service will handle the outgoing webhook request from slack.

Use the echo-api as *API URL* `https://echo-api.herokuapp.com`

Copy *APItool URL* that should look like `https://SOMETHING.my.apitools.com/`.
Go back to the *Outgoing webhook* config page you previsouly created. Pasted the APItools URL in the *URLs* field.

![Add APItools URL to outgoing webhook](https://i.imgur.com/QCL5rHP.png)

On APItools, on your newly created service, go in the pipeline and paste the code found in the file `hook.lua` of this repo.

On this code couple of placeholders have to be changed:

`SLACK_HOOK_URL` with the Slack incoming webhook URL

`BREEZ_APITOOLS_URL` with the APItools URL for breezometer service

`BREEZ_API_KEY` with your personal API key from Breezometer