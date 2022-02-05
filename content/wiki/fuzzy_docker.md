+++
title = "Run docker commands using fzf to search the containers"
date = 2022-02-04
tags = ["fzf","docker","util","wiki"]
draft = false
+++

Sometimes I find myself running commands on containers or reading logs. In order to achieve my order I need to
first get the container name with `docker ps`, copy the container name and then run the desired command. Today 
I wrote this 2 `zsh` functions to avoid this.

## fdex

This first function stands for "fuzzy docker exec", it parses the output from `docker ps` with `awk`, get the last 
column where the container names appears and then passes it to `fzf`. From `fzf` I can select a container where I 
want to enter, store it and finally run `docker exec` to that container.

```bash
function fdex() {
	CONTAINER=`docker ps | rg -v CONTAINER | awk '-F ' ' {print $NF}' | fzf`
	if [ ! -z $CONTAINER ]
	then
		docker exec -it $CONTAINER bash
	fi
}
```

I run ripgrep with the reverse match option to filter out the first line which is not interesting because it 
does not contains any running docker information.

## fdlog

This one stands for "fuzzy docker logs" and basically it is the same function, running docker logs at the end.

```bash
function fdex() {
	CONTAINER=`docker ps | rg -v CONTAINER | awk '-F ' ' {print $NF}' | fzf`
	if [ ! -z $CONTAINER ]
	then
		docker logs -f $CONTAINER
	fi
}

