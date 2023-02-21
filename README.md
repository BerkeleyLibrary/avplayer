# AV Player

The UC Berkeley Library audio/video player.

## Servers

Staging: [avplayer.ucblib.org](https://avplayer.ucblib.org/).

Production: [avplayer.lib.berkeley.edu](https://avplayer.lib.berkeley.edu/)
(Note: The production server does not display a home page.)

### Logging

Staging and production logs are aggregated in Amazon CloudWatch.

- [staging](https://us-west-1.console.aws.amazon.com/cloudwatch/home?region=us-west-1#logStream:group=staging/avplayer/rails;streamFilter=typeLogStreamPrefix)
- [production](https://us-west-1.console.aws.amazon.com/cloudwatch/home?region=us-west-1#logStream:group=production/avplayer/rails;streamFilter=typeLogStreamPrefix)

You'll need to sign in with the IAM account alias `uc-berkeley-library-it`
and then with your IAM user name and password (created by the DevOps team).

## Development

1. Build the images:

    ```sh
    docker-compose build --pull
    ```  

2. Bring up the application container:

   ```sh
   docker-compose up -d
   ```

### Viewing logs

You can view application output directly in the console by running
`docker-compose up` without the `-d` (detach) flag, or use:

```sh
docker-compose logs -f
```
