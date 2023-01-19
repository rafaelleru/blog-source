+++
title = "07 - Managing dotfiles with Ansible"
date = 2021-11-24
tags = ["dotfiles","linux","automation","ansible"]
draft = false
+++

## 1. Why Ansible

Ansible is a standard in the industry to automate deployments and provision virtual machines in the DevOps landscape. The main reason to use ansible to manage my dotfiles was to learn how to use it. 

Yes, Ansible seems to be overkill for this purpose. Dotbot seems to be a much smaller tool. Also, [Greg Hurrel](https://twitter.com/wincent) has created a config framework called [fig](https://github.com/wincen), bothered for the size and bloat that Ansible represents. 
   
I decided to go with Ansible, mainly to try it. A feature that also I liked a lot about Ansible is that it is stateless, so you don't need an agent running in the target machine as you need for puppet for example. It runs only in one machine and it connects to the machines you want to provision and execute commands there.

## 2. Ansible vs [dotbot](https://github.com/anishathalye/dotbot)

Dotbot is pretty cool, and so useful but It is so simple. Building packages, setting up complicated environments as mine becomes a mess, I had to use custom scripts setting up things before and after dotbot, calling scripts from dotbot itself...

Ansible otherwise is a tool that was created to setup and maintain complex environments so doing this becomes in a much simpler task.

## 3. Testing the installation without breaking anything.

For the shake of science I decided to test this migration using docker (It bothers me a lot to create and configure virtual machines) so I downloaded an image for each OS that I use to run, and I created a file to store the hosts to test.

```yaml
[docker]
ubuntu_docker
fedora_docker
archlinux_docker

[docker:vars]
ansible_connection=docker
```

Running Ansible from my host to each of 3 dockers seemed a reasonable approach, but Ansible takes the $HOME variable from the localhost instead of taking it from each target and it ended up causing some troubles, so I ended up running it locally in each container, also is how I will run it in each new configured machine so it makes sense.  For that my Ansible hosts looks like this:

```yaml
[local]
localhost

[local:vars]
ansible_connection=local
```

And the command to run Ansible is:

```bash
$ ansible-playbook -i ansible/hosts ansible/setup.yml
```

## 4. Replacing dotbot with Ansible → The dotfile role

Dotbot can do a lot of things, it even can run shell commands. I have been using dotbot without any issue for a long time but I never liked it completely, My install.conf.yml was a bit messy, probably it was my fault but I never felt completely comfortable with it.

To replace the main task that dotbot did I created a file with some ansible tasks that create some syslinks from my config repository to my home directory. The complete file can be found [here](https://github.com/rafaelleru/dotfiles/blob/ansible/ansible/roles/dotfiles.yml), and a simple task  from it looks like: 

  

```yaml
- name: links nvim dotfiles/config dir in ~/.config
  file:
    src: "{{ lookup('env', 'HOME') }}/dotfiles/config/nvim"
    dest: "{{ lookup('env', 'HOME') }}/.config/nvim"
    state: link
    force: yes
```

In the future maybe I can replace the location of the dotfiles repository to be `pwd` since right now I am cloning my repository twice.

## 5. Installing awesome packages with ansible

With dotbot a task that always bothered me a lot was to install all the packages that I use manually, and since Ansible is a tool for provision machines it comes with tools to do this automatically. 

I created a file with a task for each of the system packages that my distributions uses. The one for dnf looks like this:

 

```yaml
---
- name: Install apt packages
  tags: dnf
  dnf:
    name: "{{ item }}"
    state: present
  loop:
    - jq
		- ...
```

This task will iterate the items in the loop and install them if they are not present in the system. Initially, I wrote more than  2 tasks for this purpose, please don't be like me, read the docs, Ansible has you covered for this kind of repetitive task with loops and conditional tasks.

To be able to run each task file depending on the OS I use 3 conditional imports in the main playbook that check the OS family to use the right package manager:

```yaml
- name: Install apt packages
    import_tasks: roles/apt.yml
    when: ansible_facts['os_family'] == "Debian"
```

You can check your OS family in this post: [https://techviewleo.com/list-of-ansible-os-family-distributions-facts/](https://techviewleo.com/list-of-ansible-os-family-distributions-facts/)

I still have to maintain 3 lists of packages and that sucks but that isn't a problem with Ansible, is my problem because I use 3 Linux distros... 

## 6. Configuring a new fresh machine from scratch.

With all the previous steps set configuring a new PC now consists of 3 steps (4 if you are using ubuntu and apt... 😒)

 

```bash
$ sudo apt-update
$ sudo apt install ansible git
$ git clone https://github.com/rafaelleru/dotfiles && cd dotfiles
$ ansible-playbook -i ansible/hosts --ask-become-pass ansible/setup.yml
```

