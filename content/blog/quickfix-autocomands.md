+++
title = "Toggle vim QuickFix list, the right way"
date = 2021-06-26
tags = ["vim","quickfix-list"]
draft = false
+++

The Primeagean has a great [video](https://www.youtube.com/watch?v=IoyW8XYGqjM) talking about all the great 
things you can get by using QuickFix lists and local QuickFix lists. After watching it I quickly grab the following 
code and paste it to my [config](https://github.com/rafaelleru/dotfiles/tree/master/config/nvim).

```
let g:the_primeagen_qf_l = 0
let g:the_primeagen_qf_g = 0

fun! ToggleQFList(global)
    if a:global
        if g:the_primeagen_qf_g == 1
            let g:the_primeagen_qf_g = 0
            cclose
        else
            let g:the_primeagen_qf_g = 1
            copen
        end
    else
        if g:the_primeagen_qf_l == 1
            let g:the_primeagen_qf_l = 0
            lclose
        else
            let g:the_primeagen_qf_l = 1
            lopen
        end
    endif
endfun
```

This code will allow us to toggle both the LocalFix list and the QuickFix list by calling this function. In my
case, I mapped `CTRL-q` to open the global QuickFix list and `,-q` to open the local QuickFix list, because `,`
is my local leader.

## Autocomands, where the fun part begins.

With the previous code, I was able to jump both across my projects and through a file using Quickfix lists. For
example `:Rg` will populate the global QuickFix list with the occurrences that `vimgrep` find across the project.

I thought that a useful way to use local lists would be to populate it with linting and code errors and `neovim`
new LSP capabilities allow us to do it  by using `:lua vim.lsp.diagnostic.set_loclist()`. When called you will
get a local QuickFix list populated with all the LSP errors and warnings in the buffer, but I did not like the 
idea of setting the Locallist manually each time. To avoid that nvim provides the event `LspDiagnosticsChanged`.

Using `LspDiagnosticsChanged` we can set an autocomand that will populate the Locallist automatically per file.
The code is:

```
augroup locallist
    autocmd!
    " Populate locallist with lsp diagnostics automatically 
    autocmd User LspDiagnosticsChanged :lua vim.lsp.diagnostic.set_loclist({open_loclist = false})
augroup END
```

To tell nvim to do it in background we need to pass the `{open_loclist = false}`  parameter.

## Fixing ToggleQFList

Et voila! We have 2 use cases when we can populate QuickFix lists and we have 2 cool shortcuts to quickly open
and close those windows. Well...  the ToggleQFList presents a problem, if you open any of the QuickFix lists 
using another command rather than calling our function the variables `g:the_primeagen_qf_l` and `g:the_primeagen_qf_g`
will not be updated.  To fix that behavior we will use again autocomands!

We can set an autocomand that will be called each time a `quickfix` window will be created and update there our
variables. 

```
augroup fixlist
    autocmd!
    autocmd BufWinEnter quickfix call SetQFControlVariable()
    autocmd BufWinLeave * call UnsetQFControlVariable()
augroup END
```

We do the same when leaving a window to unset the variable, but for any reason, we need to use `*` instead of 
`quicxfix` when using `BufWinLeave`.

The functions that control now  `g:the_primeagen_qf_l` and `g:the_primeagen_qf_g` are `SetQFControlVariable()`
and `UnsetQFControlVariable()`. Those functions check the current vim window type and set our control variables
as needed.  

```
fun! SetQFControlVariable()
    if getwininfo(win_getid())[0]['loclist'] == 1
        let g:the_primeagen_qf_l = 1
    else
        let g:the_primeagen_qf_g = 1
    end
endfun

fun! UnsetQFControlVariable()
    if getwininfo(win_getid())[0]['loclist'] == 1
        let g:the_primeagen_qf_l = 0
    else
        let g:the_primeagen_qf_g = 0
    end
endfun
```

Now the `ToggleQFList` do not need to control the window only call `cclose`, `ccopen`, `lclose` or `lopen`
when we call it, so finally `ToggleQFList` looks like this:

```
fun! ToggleQFList(global)
    if a:global
        if g:the_primeagen_qf_g == 1
            cclose
        else
            copen
        end
    else
        echo 'toggle locallist'
        if g:the_primeagen_qf_l == 1
            lclose
        else
            lopen
        end
    endif
endfun
```

I hope it helps!
