# Containerized WordPress

This is a template for deploying a WordPress website in a Docker container.

## Requirements
 
- Docker

## Quickstart

1. Clone the repository: `git clone https://github.com/joseprsm/docker-wp.git`
2. Build your Docker image (or use the default GitHub Actions workflow): `docker build . -t docker-wp`
3. Run the Docker container: `docker run -p 8080:8080 docker-wp`

The last command will launch a new container and expose it on port 8080. You can access your new WordPress website by going to http://localhost:8080 in your web browser. After you're done creating your website, [export it](https://wordpress.com/support/export/#export-content-to-another-word-press-site) and place it under `templates/`. 

All you have to do then is re-build and push the Docker image to a registry, from where you can then deploy wherever you want. 

## Adding Plugins

You can add plugins to your WordPress installation using the `PLUGINS` build argument. To add plugins, simply add them as a JSON list while building the Docker image. For example:

```shell
docker build . -t docker-wp --build-arg PLUGINS='["contact-form-7", "wp-super-cache"]'
```

After rebuilding the Docker image, the plugins will be automatically installed and activated when the container starts up.

Alternatively, you can add your plugins to the `plugins/` folder. During the build, all the plugins under this directory will be installed and activated.

## License

This project is licensed under the [MIT License](https://github.com/joseprsm/docker-wp/blob/main/LICENSE).