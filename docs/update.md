# To update the AV run the following:

```bash
$ docker run --name=drweb malice/drweb update
```

## Then to use the updated AVG container:

```bash
$ docker commit drweb malice/drweb:updated
$ docker rm drweb # clean up updated container
$ docker run --rm malice/drweb:updated EICAR
```
