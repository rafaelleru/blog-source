+++
title = "Running DWM on hdpi displays"
date = 2022-01-20
tags = ["dwm","hdpi","wiki"]
draft = false
+++

Dwm seems to have some problems with high DPI displays, to solve it write this into `~/.Xresources`

```
Xft.dpi: 144
```

This will fix the small dwm and apps painting for screens with 3840x2160 resolution.

