# dev-container-base

A container with my basic dev tools running on Ubuntu. It does not have any languages or their specific tools installed. This could be used as a base image for developing in a specific language. Access is via SSH with the account `dev`, which has sudo.

I stole much of this from Don Petersen's excellent [repo](https://github.com/dpetersen/dev-container-base)

## Starting

Use gce kubernetes. Set an env called AUTHORIZED_GH_USERS to `amonks`.

If the GitHub API is down or the user doesn't exist / has no keys, you'll get an error.

## Connecting

You have the running container, and now it's time to pair. Except you keep forgetting the IP address and the port and the username, and you're sick of having to copy your SSH private key over to the server. Do what the pros do and set up an alias! In `~/.ssh/config`, add something like this:

```
Host devbox
  HostName <YOUR IP OR HOSTNAME>
  Port <YOUR MAPPED SSH PORT FROM ABOVE>
  User dev
  ForwardAgent true
# Feel free to leave this out if you find it unsafe. I tear down
# my dev box frequently and am sick of the warnings about the 
# changed host.
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
```

And now can:

```bash
ssh devbox
```

And everything is magically handled for you! You may have to configure your SSH client to allow SSH forwarding, but it will allow you to `git push` to private repositories without having to authenticate every time, and without copying your key to the server (where it can be lost if the container stops).

## Development

Since I build images roughly once per year, I need to remind myself how to do it. A few Top Tips below:

#### Building

```bash
gcloud docker -- build .
```
*Did you update something that won't trigger a Dockerfile change, like push to your vimfiles? Use the `--no-cache` flag.*

#### Tagging

```bash
gcloud docker -- tag <YOUR SHA HERE> dpetersen/dev-container-base:v1
```

*Don't forget to tag `latest`! It's a manual process, not magic!*

```bash
gcloud docker -- push gcr.io/dev-[numbers]/v1
```

