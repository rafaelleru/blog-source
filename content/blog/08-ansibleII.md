+++
title = "08 - Managing dotfiles with Ansible (II)"
date = 2022-01-26
tags = ["dotfiles","linux","automation","ansible"]
draft = false
+++

Apart from linking my config files, I needed to build and install a bunch of programs in each new machine I set up,
so I was using some bash scripts. I decided to use ansible for this task because it fits perfectly my needs to do this.

In this post, there are some examples of programs I am building manually with ansible, my reasons, and some thoughts.

## 1. Building my neovim copy → The neovim role

By default ubuntu repositories have a very old neovim version (the last time I installed neovim from ubuntu LSP was not available, but it was ready in the master branch of the project). This and my tendency to use always the newer version to try new things asap ended up with a local build of the master branch of the project in all my machines, so this was the first program manual installation that I automated with ansible.

```yaml
- name: get neovim repository
  git:
    force: yes
    repo: https://github.com/neovim/neovim
    dest: "{{ lookup('env', 'HOME') }}/bin/neovim"

- name: make neovim
  make:
    chdir: "{{ lookup('env', 'HOME') }}/bin/neovim"
    target: install
```

These 2 tasks simply clone the neovim repository using the `git` plugin from ansible and build it using the `make` plugin. 

Currently this role 2  problems, I am getting an error from git if the repository exists locally due to the release version and I am not able to build neovim using 4 jobs, I tried both with the `jobs` parameter of the plugin and using the `params` parameter, but none of them worked fine. I will revisit this in the future, it is a bit annoying.

## 2. Building my dwm copy → The dwm role
To build `dwm` first I needed to link my config file to my dwm patched code, so first I need to clone my dwm repository, as I did for neovim, from Github:

```yaml
- name: clone my dwm copy
    git:
      repo: https://github.com/rafaelleru/dwm.git
      dest: "{{ lookup('env', 'HOME') }}/bin/dwm"
```

Then after setting up the dotfiles which include the `config.h` file for dwm as I explained in part I of this post, I can build and install `dwm` using the make plugin with this code:

```yaml
- name: build my dwm copy
  make:
    chdir: "{{ lookup('env', 'HOME') }}/bin/dwm"
    target: install
```

## 3. Installing rust, cargo, and building my alacrity copy

My terminal emulator has been alacrity for more than 3 years now, it is written in rust and claims to be the fastest terminal in the world, I don't use it because of any of that. It is simple, supports well utf-8 fonts, and can be configured with a single yaml file that I can version. 

In ubuntu, you can install alacrity via snap or build your own but alacrity changes configuration options between versions that end up with some warnings so I want to install the same version of alacrity in all my machines. To do that I decided to manually install rust, and build my alacrity copy with ansible. It is done in 6  tasks: 

The first tasks are used to get Linux’s `[rustup-init.sh](http://rustup-init.sh)` script, give it permissions to run, and run it to install rust locally 

```yaml
- name: get rustup script
  tags: alacritty
  get_url:
    url: https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init
    dest: "{{ lookup('env', 'HOME') }}/bin/rustup-init.sh"

- name: give rustup permissions to run
  tags: alacritty
  shell: "chmod 755 {{ lookup('env', 'HOME') }}/bin/rustup-init.sh

# TODO: Instalar rust
- name: run rustup.sh script
  tags: alacritty
  shell: "{{ lookup('env', 'HOME') }}/bin/rustup-init.sh -y"
```

Then I download alacrity code from Github

```yaml
- name: clone alacritty source code
  tags: alacritty
  git:
    repo: https://github.com/alacritty/alacritty.git
    dest: "{{ lookup('env', 'HOME') }}/bin/alacritty"
```

This is the most troublesome step, I wanted to do it in multiple steps but every single task in Ansible is run independently, so they don’t inherit environment variables from previous steps for example you can not run source in 1 step and use a variable from that source in the next task, so I ended up chaining 4 commands in a single ansible task to build alacrity using my local cargo:

```yaml
- name: enable cargo
  tags: alacritty
  shell:
    chdir: "{{ lookup('env', 'HOME') }}/bin/alacritty"
    cmd: "source {{ lookup('env', 'HOME') }}/.cargo/env
       && rustup override set stable
       && rustup update stable
       && cargo build --release"
    executable: /bin/yaml
```

Finally, since I am root in all my machines I copy alacrity to the `/usr/bin` directory to have it available for all the users.

```yaml
- name: place alacritty in /usr/bin directory
  tags: alacritty
  file:
    src: "{{ lookup('env', 'HOME') }}/bin/alacritty/target/release/alacritty"
    dest: "/usr/bin/alacritty"
    state: link
    force: yes
```
    
## 4. Other packages manually installed with ansible.
There are more packages that I am installing manually with Ansible such as `fzf` or `clipnotify`, you can find more exploring the ansible directory in my dotfiles repository. 
It is amazing how easy is to automate all these tasks, you can avoid custom shell scripts that, at least for me, most of the time failed.

## 5. In the future.
I want to fix the problems of cloning neovim, also even it is working I don’t like the way I am building alacrity in one simple task and I am sure ansible provides mechanisms to it more elegantly and safely. 
Last but not least I want to link a couple of videos from youtube that helped me to start with Ansible, and give me ideas to use it in the future:

- [Ansible 101 - Episode 1 - Introduction to Ansible](https://www.youtube.com/watch?v=goclfp6a2IQ) by [@geerlingguy](https://twitter.com/geerlingguy)
- [Writing Your First Ansible Playbook! | IaC Deep Dive Pt. 1](https://www.youtube.com/watch?v=Z7p9-m4cimg) by [@nothebee](https://twitter.com/notthebeeee)
    
For sure I will continue using Ansible to automate everything I can in my future machines, for example, I am building a homelab and I am sure ansible will be so useful for that.

