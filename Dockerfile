# v46
FROM ubuntu:latest
MAINTAINER Andrew Monks <a@monks.co>

# Start by changing the apt output, as stolen from Discourse's Dockerfiles.
RUN \
    echo "debconf debconf/frontend select Teletype" | debconf-set-selections &&\
# Probably a good idea
    apt-get update

RUN \
# Fix for occasional errors in perl stuff (git, ack) saying that locale vars
# aren't set.
    locale-gen en_US en_US.UTF-8 && dpkg-reconfigure locales

RUN \
# Basic dev tools
    apt-get install -y sudo openssh-client git build-essential vim ctags man curl direnv software-properties-common

RUN \
# Install tmux and mosh
    apt-get install -y tmux mosh

RUN \
# Install neovim
    add-apt-repository ppa:neovim-ppa/unstable &&\
    apt-get update &&\
    apt-get install neovim

RUN \
# Install ruby
    apt-get install -y ruby

RUN \
# Install the Github Auth gem, which will be used to get SSH keys from GitHub
# to authorize users for SSH
    gem install github-auth --no-rdoc --no-ri

RUN \
# Set up SSH. We set up SSH forwarding so that transactions like git pushes
# from the container happen magically.
    apt-get install -y openssh-server &&\
    mkdir /var/run/sshd &&\
    echo "AllowAgentForwarding yes" >> /etc/ssh/sshd_config

RUN \
# install fish
    add-apt-repository ppa:fish-shell/nightly-master &&\
    apt-get update &&\
    apt-get install -y fish

RUN \
# install cli utils
    apt-get install -y autojump &&\
    apt-get install -y silversearcher-ag

RUN \
# install node
    curl -sL https://deb.nodesource.com/setup_7.x | bash &&\
    apt-get install -y nodejs

RUN \
# install yarn
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - &&\
    echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list &&\
    apt-get update &&\
    apt-get install yarn

RUN \
# install flow deps
    apt-get install ocaml libelf-dev

RUN \
# set up dev user
    useradd dev -d /home/dev -m -s /usr/bin/fish &&\
    adduser dev sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER dev

ADD ssh_key_adder.rb /home/dev/ssh_key_adder.rb
ADD bin /home/dev/bin

RUN \
# configure git
    git config --global user.name "Andrew Monks" &&\
    git config --global user.email "a@monks.co" &&\
    git config --global core.excludesfile ~/.config/gitignore-global
    git config --global push.default simple

RUN \
# set up oh my fish
    curl -L http://get.oh-my.fish > ~/install-omf.fish &&\
    fish ~/install-omf.fish --noninteractive &&\
    rm ~/install-omf.fish

RUN \
# this is last cuz it updates often
# do config
    git clone --bare https://github.com/amonks/cfg.git $HOME/.cfg &&\
    git --git-dir=$HOME/.cfg/ --work-tree=$HOME checkout &&\
    git --git-dir=$HOME/.cfg/ --work-tree=$HOME config --local status.showUntrackedFiles no

# Expose SSH
EXPOSE 22

# Install the SSH keys of ENV-configured GitHub users before running the SSH
# server process. See README for SSH instructions.
CMD /home/dev/ssh_key_adder.rb && sudo /usr/sbin/sshd -D

