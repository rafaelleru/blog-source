+++
title = "Small-shell con eshell"
date = 2017-05-15
tags = ["emacs,", "shell"]
draft = false
+++

Hace tiempo me encontré con una idea que me encanto, poder abrir
rapidamente una ventana en emacs que contenga un emulador de
terminal, para hacer tareas rapidas en ella. Lo ví en el archivo de
configuración de [@vterron](https://github.com/vterron/dot-emacs), la función era small-shell y lucía tal que
así:

```emacs-lisp
(defun small-shell ()
  (interactive)
  (split-window-vertically)
  (other-window 1)
  (shrink-window (- (window-height) 12))
(ansi-term))
```

Pero para mis necesidades se quedaba un poco corta, así que la
modifiqué del siguiente modo.

En primer lugar, cambiamos `ansi-term` por `eshell` que para mi gusto es
más completo y funciona mejor, con lo que la función quedaría así:

```emacs-lisp
(defun small-shell ()
  (interactive)
  (split-window-vertically)
  (other-window 1)
  (shrink-window (- (window-height) 12))
  (eshell))
```

Pero la principal pega que tenía el original era que cada vez que
invocamos a small-shell se crea una nueva instancia de `ansi-term` o
`eshell` y yo quería que `C-x k` saliese del buffer y eliminara la
ventana, con lo que añadimos el siguiente hook:

```emacs-lisp
(add-hook 'eshell-exit-hook 'delete-window)
```

Por último creamos un atajo de teclado personalizado que invoque a
small-shell y listo tenemos en todo momento un terminal listo con el
cual desde dentro de nuestro editor podemos por ejemplo desplegar este
artículo.

```emacs-lisp
(global-set-key (kbd "C-ñ") 'small-shell)
```
