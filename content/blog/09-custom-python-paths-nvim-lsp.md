+++
title = "09 - Use custom python paths on neovim lsp client"
date = 2022-09-14
tags = ["python","linux","airflow","nvim", "vim"]
draft = false
+++

Recently we started to use airflow in my current company, and I found an issue, LSP was not recognisin our 
custom plugins and DAGS inside of the `airflow` folder. This was caused because airflow is also a package that
is installed in my virtualenv, so jedi was not able to discover definitions for example. 

That was caused because in my `PYTHONPATH` airflow was a package, so jedi was not looking into the `airflow` 
folder for more source code, causing LSP functionality to not work fine. So the solution was to add my `$PROJECT/airflow`
to the `sys.path` value for python.

There is multiple ways to achieve this.

# 1. Using custom settings on nvim lsp client for python.

I use `pylsp` server to get python LSP functionality in neovim, and checking the 
[documentation](https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md) I found that you
can pass to jedi the option `extra_paths` to indicate jedi that you want to use that list and append it to 
the python path to discover source code. So I configured `pylsp` in my `init.vim` to add my custom airflow 
path when running the LSP client. 

```lua
require'lspconfig'.pylsp.setup{
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = {
          maxLineLength = 120
        },
        jedi = {
          extra_paths = {'/home/rafa/my_project/airflow'}
        }
      }
    }
  }
}
```

But this approach did not convinced me, that will load always that absolute path even if I am working on some
other python project. Also I did not like the idea of having some project specific configuration added to my 
neovim config, that is supossed to work always for all my projects.


# 2. Updating the PYTHONPATH of a python virtualenv.

The best option seemed to be to create a virtualenv for that project development, and tunning it to add my custom
path to its `PYTHONPATH`. You can do this by adding a `path.cfg` file to the `site_packages` of the virtualenv
but I found a wrapper over virtualenv that allow you to this king of things without messing with the env files.

It is called `virtualenvwrapper`, and once it is installed in your virtualenv you need to add this line to the file
 `<venv-name>/bin/activate`:

 ```bash
 source $VIRTUAL_ENV/bin/virtualenvwrapper.sh
 ```

 After that once you have activated the virtualenv you only need to run this command:

 ```
 add2virtualenv airflow/plugins/  
 ```

 And that will set up the virtualenv to add `airflow/plugins/` to the `PYTHONPATH` on the virtualenv automatically
 once that you activate it. 

 With that the LSP client was now working perfectly, but I did not like the idea of having to enable always the 
 virtualenv manually, because this kind of operation would be forgotten a lot of times. 


# 3. Use direnv to automatically enable the virtualenv.

I found this utility that allow you to customize your shell environment per directory, it basically reads the 
`.envrc` file if it exitst in the folder, evaluates it and create a new shell environment that will be enabled
once that you enter to the directory, it is like magic.

So the only thing I was missing to make the LSP client work perfectly allways in my airflow project was to create
a new `.envrc` file with this content in my project folder:

```bash
source env/bin/activate
```

# 4. Conclusion.

This is a good approach to do 2 things, automatically work with venvs per project saving us problems related to 
multiple python version or package conflicts and make use of custom namespaces that may overwrite default 
python names. 


Enjoy!
