+++
title = "05 - JSON magic with VIM"
date = 2021-05-07
tags = ["vim","json"]
draft = false
+++

# How to edit, compare, and pretty format JSONs only with VIM (and maybe some other CLI tool)

I have been comparing multiple versions of the same JSON file in my daily workflow, having to edit it and converting it from one line to pretty and vice-versa. For that purpose, I was copying the JSON to a website called [JSON formatter and validator](https://jsonformatter.curiousconcept.com/) (There are hundreds of sites with the same objective around in the internet) and then comparing it to his also prettified version using [JSON diff](http://www.jsondiff.com/). This consisted of 4 copy-paste operations all of them involving the mouse. This is slow and tedious and I knew it could be done with vim, but I was lazy about learning how to do it, but I finally did it. On the way, I also started playing around with vim tabs.

![Demo](./img/05-07-2021/demo.gif)

## 1 Prettify a JSON buffer in VIM.

There are hundreds of plugins that can do that in VIM with one simple command, but I was already using jq as my goto JSON tool in the CLI and then I found that you can pipe a whole VIM buffer into any program that you like, so I ended up with the following command: `:%!jq '.'`.
The `%` symbol represents the content of the current buffer, `!` passes the previous text to an external program, in this case, `jq`. Finally jq knows how to prettify a JSON for us, the  `'.'` final in the command can be omitted, it is only some standard stuff for the pretty JSON format.


## 2 Enabling diff for 2 splitted windows in vim

I knew VIM comes with a diff mode. It can be enabled with the command `:windo diffthis`. `:windo` will execute the following command in all windows in a VIM tab. The command I am using is diffthis, which adds the current window to the list of "diffs windows". You can also run `:diffthis` in multiple windows separately and it will give you the diff of those windows.

## 3 Opening new buffers with `:enew`

If we have let's say a dataset with hundreds of JSONs inside it will be so tedious to check the diff for all of the entries, so I usually open a new unnamed buffer with `:enew` and paste inside the JSON that I want to check.

So to compare 2 JSONs side by side this is the whole command sequence you need to run:

- `:tabnew` (I like to perform this kind of operations in a new tab)
- Paste your first json from another buffer.
- `:vsplit`
- `:enew`
- `:windo %!jq` This will format both buffers simultaneously.
- `:windo diffthis`
- `:tabcl` to close up the tab, once you have finished checking and editing your jsons.

I will not use anymore tools like the 2 websites named at the begining of this article, I hope you neither, VIM 
can manage this and much more!

[My vim config](https://github.com/rafaelleru/dotfiles/blob/master/config/nvim/init.vim)
