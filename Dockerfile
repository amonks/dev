# v42
FROM ubuntu:latest
MAINTAINER Andrew Monks <a@monks.co>

# Start by changing the apt output, as stolen from Discourse's Dockerfiles.
RUN \
    echo "debconf debconf/frontend select Teletype" | debconf-set-selections &&\
# Probably a good idea
    apt-get update

RUN \
# Basic dev tools
    apt-get install -y sudo openssh-client git build-essential vim ctags man curl direnv software-properties-common

RUN \
# Install tmux
    apt-get install -y tmux

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
# Fix for occasional errors in perl stuff (git, ack) saying that locale vars
# aren't set.
    locale-gen en_US en_US.UTF-8 && dpkg-reconfigure locales

RUN useradd dev -d /home/dev -m &&\
    adduser dev sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN \
    curl -sL https://deb.nodesource.com/setup_7.x | bash &&\
    apt-get install -y nodejs

RUN \
    apt-get install -y fish &&\
    apt-get install -y autojump

USER dev

ADD ssh_key_adder.rb /home/dev/ssh_key_adder.rb

# Expose SSH
EXPOSE 22

# Install the SSH keys of ENV-configured GitHub users before running the SSH
# server process. See README for SSH instructions.
CMD /home/dev/ssh_key_adder.rb && sudo /usr/sbin/sshd -D

