+++
title = "Seleccionando de una manera mas inteligente en emacs"
tags = ["emacs"]
draft = false
+++

El otro día viendo la serie de videos de [Myke Zamansky](http://cestlaz.github.io) sobre emacs,
habló sobre un paquete de emacs llamado expand-region. El
funcionamiento es muy sencillo nos permite seleccionar con una sola
pulsación en el atajo que definamos el texto entre dos delimitadores,
ya sean parentesis, comillas, etc.

Para usarlo lo primero es instalarlo, ejecutando en emacs `M-x` y
escribiendo `package-install RET expand-region RET` donde RET es la
tecla enter.

Despues añadimos a nuestro <span class="underline">init.el</span> lo siguiente:

```emacs-lisp
(require 'expand-region)
(global-set-key (kbd "C-=") 'er/expand-region)
```

En mi caso comence usando `C-ç` pero me resultaba extraño y lo cambie por `C-=`.
