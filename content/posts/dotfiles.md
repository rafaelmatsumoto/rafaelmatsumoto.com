---
title: "Dotfiles"
date: 2020-07-22T22:53:00-03:00
description: "What are dotfiles and why use them?"
draft: false
tags: [general]
---

# What are dotfiles?

Dotfiles are configuration files used in Unix-based operating systems to configure tools like vim, zsh, npm, etc.

The name comes from the fact that they usually start with a '.' as the first character, making them hidden files.

Since dotfiles are just text files, they are perfect for hosting in a GitHub repository.

# Why use dotfiles?

Over the years, you'll likely start automating and configuring your operating system to best fit your workflow. You'll also probably switch operating systems (especially if you're on Linux) several times, and configuring the entire system each time can be extremely tedious.

Therefore, dotfiles are a relatively simple way to manage your personal configuration. Additionally, it's probably the only code project a developer will carry for the rest of their life.

# How to manage dotfiles?

There are several strategies for managing dotfiles and configuration files. I found some good tutorials at:

- https://www.atlassian.com/git/tutorials/dotfiles

- https://www.anishathalye.com/2014/08/03/managing-your-dotfiles/

- https://yadm.io/docs/getting_started#
