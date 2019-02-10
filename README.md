# malice-drweb

[![Circle CI](https://circleci.com/gh/malice-plugins/drweb.png?style=shield)](https://circleci.com/gh/malice-plugins/drweb) [![License](http://img.shields.io/:license-mit-blue.svg)](http://doge.mit-license.org) [![Docker Stars](https://img.shields.io/docker/stars/malice/drweb.svg)](https://store.docker.com/community/images/malice/drweb) [![Docker Pulls](https://img.shields.io/docker/pulls/malice/drweb.svg)](https://store.docker.com/community/images/malice/drweb) [![Docker Image](https://img.shields.io/badge/docker%20image-1.02GB-blue.svg)](https://store.docker.com/community/images/malice/drweb)

Malice Dr.WEB AntiVirus Plugin

> This repository contains a **Dockerfile** of [drweb](https://www.drweb.com/).

---

### Dependencies

- [debian:jessie-slim (_79.2 MB_\)](https://hub.docker.com/_/debian/)

## Installation

1. Install [Docker](https://www.docker.com/).
2. Download [trusted build](https://store.docker.com/community/images/malice/drweb) from public [docker store](https://store.docker.com): `docker pull malice/drweb`

## Usage

```
docker run --rm malice/drweb EICAR
```

### Or link your own malware folder:

```bash
$ docker run --rm -v /path/to/malware:/malware:ro malice/drweb FILE

Usage: drweb [OPTIONS] COMMAND [arg...]

Malice Dr.WEB AntiVirus Plugin

Version: v0.1.0, BuildTime: 20180909

Author:
  blacktop - <https://github.com/blacktop>

Options:
  --verbose, -V          verbose output
  --elasticsearch value  elasticsearch url for Malice to store results [$MALICE_ELASTICSEARCH_URL]
  --table, -t            output as Markdown table
  --callback, -c         POST results back to Malice webhook [$MALICE_ENDPOINT]
  --proxy, -x            proxy settings for Malice webhook endpoint [$MALICE_PROXY]
  --timeout value        malice plugin timeout (in seconds) (default: 120) [$MALICE_TIMEOUT]
  --help, -h             show help
  --version, -v          print the version

Commands:
  update  Update virus definitions
  web     Create a Dr.WEB scan web service
  help    Shows a list of commands or help for one command

Run 'drweb COMMAND --help' for more information on a command.
```

## Sample Output

### [JSON](https://github.com/malice-plugins/drweb/blob/master/docs/results.json)

```json
{
  "drweb": {
    "infected": true,
    "result": "EICAR Test File (NOT a Virus!)",
    "engine": "7.00.33.06080",
    "database": "7208559",
    "updated": "20180909"
  }
}
```

### [Markdown](https://github.com/malice-plugins/drweb/blob/master/docs/SAMPLE.md)

---

#### Dr.WEB

| Infected |             Result             |    Engine     | Updated  |
| :------: | :----------------------------: | :-----------: | :------: |
|   true   | EICAR Test File (NOT a Virus!) | 7.00.33.06080 | 20180909 |

---

## Documentation

- [To write results to ElasticSearch](https://github.com/malice-plugins/drweb/blob/master/docs/elasticsearch.md)
- [To create a Dr.WEB scan micro-service](https://github.com/malice-plugins/drweb/blob/master/docs/web.md)
- [To post results to a webhook](https://github.com/malice-plugins/drweb/blob/master/docs/callback.md)
- [To update the AV definitions](https://github.com/malice-plugins/drweb/blob/master/docs/update.md)

## Issues

Find a bug? Want more features? Find something missing in the documentation? Let me know! Please don't hesitate to [file an issue](https://github.com/malice-plugins/drweb/issues/new).

## TODO

- [x] add licence expiration detection
- [ ] expose WEB ui

## CHANGELOG

See [`CHANGELOG.md`](https://github.com/malice-plugins/drweb/blob/master/CHANGELOG.md)

## Contributing

[See all contributors on GitHub](https://github.com/malice-plugins/drweb/graphs/contributors).

Please update the [CHANGELOG.md](https://github.com/malice-plugins/drweb/blob/master/CHANGELOG.md) and submit a [Pull Request on GitHub](https://help.github.com/articles/using-pull-requests/).

## License

MIT Copyright (c) 2016 **blacktop**
