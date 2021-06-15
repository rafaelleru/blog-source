+++
title = "Linux commands"
date = 2021-06-15
tags = ["commandline","wiki"]
draft = false
+++

## Get the real size of a folder

`ls` returns 4K as size for folders. To get the total size for a folder and his content run:

```
du -h --max-depth=0 <directory>
```

If you want to obtain the size of the content inside the directory: 

```
du -h --max-depth=1 <directory>
```
