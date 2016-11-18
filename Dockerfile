FROM ubuntu:latest
MAINTAINER Andrew Monks <a@monks.co>
LABEL version="v38"

# Start by changing the apt output, as stolen from Discourse's Dockerfiles.
RUN \
    echo "debconf debconf/frontend select Teletype" | debconf-set-selections &&\
# Probably a good idea
    apt-get update

RUN \
# Basic dev tools
    apt-get install -y sudo openssh-client git build-essential vim ctags man curl direnv software-properties-common

RUN \
# Set up for pairing with wemux.
    apt-get install -y tmux &&\
    git clone git://github.com/zolrath/wemux.git /usr/local/share/wemux &&\
    ln -s /usr/local/share/wemux/wemux /usr/local/bin/wemux &&\
    cp /usr/local/share/wemux/wemux.conf.example /usr/local/etc/wemux.conf &&\
    echo "host_list=(dev)" >> /usr/local/etc/wemux.conf

RUN \
# Install neovim
    add-apt-repository ppa:neovim-ppa/unstable &&\
    apt-get update &&\
    apt-get install neovim

RUN \
# Install Homesick, through which zsh and vim configurations will be installed
    apt-get install -y ruby

RUN \
# Install the Github Auth gem, which will be used to get SSH keys from GitHub
# to authorize users for SSH
    gem install github-auth --no-rdoc --no-ri

RUN \
# Install zsh
    apt-get install -y zsh

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

RUN useradd dev -d /home/dev -m -s /bin/zsh &&\
    adduser dev sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER dev

ADD ssh_key_adder.rb /home/dev/ssh_key_adder.rb

# Expose SSH
EXPOSE 22

# Install the SSH keys of ENV-configured GitHub users before running the SSH
# server process. See README for SSH instructions.
CMD /home/dev/ssh_key_adder.rb && sudo /usr/sbin/sshd -D

