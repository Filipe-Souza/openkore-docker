# OpenKore - Container image

This repository holds a implementation of a container image to run OpenKore.

The OpenKore version is locked in a commit hash defined on the [Dockerfile](Dockerfile) OPENKORE_VER_COMMIT enviroment variable

Everything here was tested on Linux (Ubuntu 22.04).

This repo includes a OpenKore plugin that allow the bots to walk randomly through maps.

## Setup

You should know how to configure and get a OpenKore client running. If not, I suggest going into the [project repository](https://github.com/OpenKore/openkore)
and setting up your working configuration.

### Build the image

First you're going need the get your tables/servers.txt configuration block and attribute it to a shell environment variable, example from a rAthena server configuration:

```text
SERVER_CONFIG='
[rAthena]
ip 127.0.0.1
port 6900
version 128
master_version 55
serverType kRO_RagexeRE_2020_04_01b
serverEncoding Western
charBlockSize 155
addTableFolders kRO/RagexeRE_2020_04_01b;translated/kRO_english;kRO

# Following parameters are optional, depending on your server configuration.
private 1
pincode 1020
'
```

Build your container image:

```bash
docker build -t openkore .
```

### Running

You should have at least one control/config.txt working with the OpenKore client. Check the [project repository](https://github.com/OpenKore/openkore) for more information configuring it.

Create a directory named .config and place your control/config.txt files there, renaming then as needed.

After that, run the container

```bash
docker run -it -v $PWD/.config/config.txt:/tmp/config.txt openkore perl openkore.pl --config=/tmp/config.txt
```

Or you can run it with the --env flag
```bash
docker run -it --env SERVER_BLOCK="${SERVER_CONFIG}" -v $PWD/.config/config.txt:/tmp/config.txt openkore perl openkore.pl --config=/tmp/config.txt
```

### Configuration options

| Property            | Type                          | Default value | Description                                                   |
|---------------------|-------------------------------|---------------|---------------------------------------------------------------|
| SERVER_BLOCK        | Environment variable/Argument |               | Allows inserting a server block into OpenKore configuration   |
| ENABLE_ALL_PLUGINS  | Environment variable/Argument |               | Changes OpenKore configuration to load all plugins            |
| OPENKORE_VER_COMMIT | Argument                      |1edc50f32460846e3a9d9ea58a523fb631b1ab6d| The commit hash to checkout after cloning OpenKore repository |
