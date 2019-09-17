# AV Player

The UC Berkeley Library audio/video player.

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
