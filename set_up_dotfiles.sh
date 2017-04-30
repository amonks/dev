#!/bin/bash

repo=git@github.com:amonks/cfg.git

git clone --bare $repo $HOME/.cfg

git --git-dir=$HOME/.cfg/ --work-tree=$HOME checkout

