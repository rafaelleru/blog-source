+++
title = "Mantener una lista de articulos para leer con org-mode"
tags = ["emacs,", "orgmode"]
draft = false
+++

Orgmode es le leche, no creo que pueda encontrar una frase mejor para
empezar este post. Desde hace tiempo lo uso para mantener mi lista de
TODOs, gestionar mi calendario, etc.

Aparte de lo comentado anteriormente mentengo tambien una lista de
enlaces y articulos que leer, la almaceno en un archivo llamado
`to-read.org` y hasta hace poco para abrirlo tenía que abrir emacs,
abrir el archivo y empezar a navegar por los enlaces, pero hace unos
días se me ocurrió una idea. Gracias a los múltiples backend para
exportar que tiene orgmode puedo generar un html de dicho archivo y
visitarlo desde mi navegador, pero no era cómodo generar el html cada
vez que añadia un enlace.

Para automatizarlo simplemente he creado una función en mi [archivo de
configuración](https://github.com/rafaelleru/emacs_configuration) que detecta cuando modifico `to-read.org` y automaticamente
crea el html, después simplemente añadimos un hook a org-mode para
que cada vez que se guarde el archivo genere la web que queremos
visitar desde el navegador.

La función es la siguiente:

```emacs-lisp
(defun org-mode-export-hook()
  "Auto export html"
  (when (eq major-mode 'org-mode)
    (when (equal buffer-file-name "/home/rafa/org/to-read.org")
     (org-twbs-export-to-html t))))
```

Y su cometido es detectar que está en un buffer de tipo `org-mode`, y
si el nombre del archivo que está abierto en el buffer es el índice de
enlaces para leer exportar directamente a html dicho archivo.

Para que el html no quede tan soso en vez de usar el comando
`org-html-export-to-html` he instalado el paquete `ox-twbs`. Para ello
añadimos lo siguiente a nuestro archivo de configuración (tambien
podemos instalarlo con `M-x install-package RET ox-twbs RET`)

```emacs-lisp
(use-package ox-twbs
  :ensure t)
```

`ox-twbs` nos exportar un html con un css dado, y lo hace mejor que el que
integra `org-mode` por defecto.

Por último añadimos el hook para org-mode que llame a nuestra función
cada vez que guardemos dicho archivo.

```emacs-lisp
(add-hook 'after-save-hook 'org-mode-export-hook)
```

Luego solo tenemos que abrir to-read.html en el navegador y si lo
vamos a visitar mucho añadirlo como marcador.


## EDIT: {#edit}

Tras ver que no funcionaba como esperaba consulte
<http://emacs.stackexchange.com/> y parece ser que para comparar no hay
que usar `eq` sino `equal`.
