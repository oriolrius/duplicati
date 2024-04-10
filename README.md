# Duplicati docker image with docker logs support

This image is based on the official duplicati image and adds support for docker logs. This allows you to see the duplicati logs using `docker logs`. Specially useful when you have a centralised logging system like ELK, or Grafana Loki.

## Considerations

- Duplicati doesn't support send logs to the console. 
- This image uses a workaround to send the logs to the console.
- Using "tail -F" command to follow the log file and send it to the console.
- Every day logrotate is launched to rotate the logs.
- Log files are stored in /backup folder.

## Usage

There is a docker-compose file in the repository that you can use to start the container. 

You can also use the following command to start the container: (this is how I use it)

```bash
docker run -d --name duplicati -v /:/mnt -v /backup:/backup -v ./data:/data --network host ghcr.io/oriolrius/duplicati
```

- The `-v /:/mnt` host filesystem data; data to backup (data source).
- The `-v /backup:/backup` volume is the target backup directory.
- The `-v ./data:/data` volume is duplicati configuration and database.
- The `--network host` is used to allow the container to access the host network. 

**NOTE**: All those parameters are optional. I shared them just for helping other about how do I use it.

## Build

It uses github workflows to build the image. You can also build the image locally using the following command:

```bash
docker build -t ghcr.io/oriolrius/duplicati .

or 

docker compose build
```

## Greatings

This image is based on the work of [duplicati](https://github.com/duplicati/duplicati) and [logrotate](https://github.com/logrotate/logrotate). 

Thank you for your work!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

