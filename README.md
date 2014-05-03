# Cannery: Building Pre-Packed Vagrant Boxes for Development

[Vagrant](https://www.vagrantup.com/) is a tool for creating local
virtual machines for software development. The easiest way to use it
is to download
[other people's pre-configured boxes](https://vagrantcloud.com/discover/featured)
from [Vagrant Cloud](https://vagrantcloud.com/). But depending on
other people's boxes is risky.

  - What exactly is installed on there? Can we trust it to be correct?
    Can we trust it to *stay* correct? If we discover a bug, can we
    fix it ourselves, or do we need to beg the original publisher for
    help?

  - What if the boxes are far out of date? Is there a recipe for
    automatically updating them?

  - What if we want to set up a production machine that's similar to
    the development box? Do we have a recipe?

Cannery is a collection of scripts for building and configuring my own
customized, pre-packed Vagrant boxes. These can optionally be published on
Vagrant Cloud and used by any Vagrant user in the world.

## Why Use Pre-Packed Boxes?

Vagrant is the proper tool for setting up development environments,
but people complain that it's too slow. I've heard claims of twenty
minute build times. *Forty* minutes, even! That's insane.

I can guess what's going wrong: A typical `Vagrantfile` specifies a
process like this:

  - Download and cache a
    [Vagrant base box](https://vagrantcloud.com/discover/featured)
    with, say, the stock Ubuntu 12.04 distribution installed on it.

  - Boot a VM based on this base box.

  - Download upgraded versions of all the out-of-date Linux
    packages. Ubuntu 12.04 is over two years old, so there are a *lot*
    of these.

  - Download and install additional tools for your development
    platform. This step ranges from slow (if you have to download
    Linux packages for the whole LAMP stack) to *seriously* slow (if
    you're a Ruby programmer who is *compiling Ruby from scratch* on
    every box).

The problem is all that downloading, which can easily consume twenty
minutes. Ubuntu package mirrors are not fast. Installing dozens of
Ruby, Python, or NPM packages is not fast. Compiling is *seriously*
not fast. And the next time you type `vagrant up` all of this will
happen *again*.

A better strategy for a `Vagrantfile` is this:

  - Build (or download) and cache a **pre-packed Vagrant box**
    containing updated Linux packages and pre-installed copies of your
    platform's stack and tools.

  - Boot a VM based on this box.

  - Run a configuration management script that upgrades all packages,
    just in case. Hopefully the pre-packed box is not long out of
    date, so this script will have little to do.

The pre-packed box can be big -- my Rails one is pushing 1GB -- but
*Vagrant only needs to download it once*, after which it gets locally
cached. Then you can spin up one VM after another. I can type `vagrant
up` in a Rails 4.1 project and have the VM up in two minutes, provided
I start with a box that *already has Ruby, Rails, and all their
dependencies installed*.

Why don't people do this? Because automating the creation of
pre-packed Vagrant boxes requires a handful of fiddly scripts. But you
can get a head-start by copying the scripts in this repository.

## What's Here?

  - Each directory inside the `distros` directory contains a
    [Packer](http://www.packer.io) recipe for building a Vagrant base
    box directly from official Linux ISO images. This is for
    serious-minded (read "paranoid") ops engineers. More casual
    developers might prefer to just edit their `baseboxes`
    Vagrantfiles to start with
    [a box from Vagrant Cloud](https://vagrantcloud.com/discover/featured).

  - The `baseboxes` directory contains builds for different flavors of
    Vagrant box. Each of these depends on a `distro` box, but adds
    extra packages and configuration to support a specific software
    stack, such as Ruby or PHP.

  - The `bin` directory contains utilities for the build process.

## Building a Base Box

  1. `cd` into the appropriate `baseboxes` subdirectory.
  2. Type `make`.
  3. Wait a few minutes while various packages download and install.
  4. A `.box` file is now sitting in your current directory. Use `ls -l` to admire it.
  5. Type `make install` to add the box to your local machine.
  6. Alternatively, use `make upload` to send the box up to S3. You'll need an S3 account; see below.

### Boxes, Box Files, and VMs

Like many software systems, Vagrant is potentially confusing because
it's layered:

  - A running *virtual machine* (VM) is what you'll be using for
    development. You'll access it via `vagrant ssh`.
  
  - Your VM might be either running, suspended, or halted at any given
    moment. `vagrant status` will tell you. A suspended VM is taking
    up disk space, but not RAM or compute cycles. You can suspend a VM
    with `vagrant suspend` (and resume it with `vagrant resume`), shut
    down a VM with `vagrant halt`, or destroy it completely with
    `vagrant destroy`.
  
  - A *box* is what project VMs are built from (using `vagrant
    up`). Each VM is a slightly different variation on a box; the
    variations are specified by the the project *Vagrantfile*. Boxes
    get installed on your machine, and you can manage the install with
    various `vagrant box` commands. For example, `vagrant box list`
    shows the list of locally installed boxes.

  - A *box file* is used to install a box on a machine. This is a file
    ending in `.box` containing a compressed copy of a machine's hard
    disk. It's typically 0.5 to 1GB in size (for the Ubuntu 12.04
    installs I've been using). Vagrant will download a box file when
    you ask it to install a box.

Once you've installed a local box from the `.box` file which these
Cannery scripts build, you may choose to delete the file from the
build subdirectory to save disk space. Although, if you're serious
about your devops workflow, you'll probably want to be sure to back
the `.box` file up first (perhaps by using `make upload` to S3),
partly as a backup, partly as documentation of what the box looked
like at this point in time, and partly so that you can share the
identical box with other computers or other developers.


## Building Your Own Distro Box

### Why?

It might seem a little obsessive to use Packer to build our own
standard Ubuntu 12.04 box from scratch, instead of downloading
[the image that Hashicorp has already built for us](https://vagrantcloud.com/hashicorp/precise64).
But, as with all dependencies, it's a question of:

  - **Certainty.** If we have the recipe for our base image, we can
    read it to figure out what's in there, and what isn't in there.

  - **Control.** We can adjust our recipe however we need to. We don't
    have to argue with anyone, let alone win that argument. We don't
    have to conform to the standard use case.

  - **Timing.** If an urgent patch comes out, we don't need to wait
    for a third party to rebuild the patched image: we can do so
    ourselves in a few minutes. More importantly: If a patch comes
    out, but that patch *breaks our software*, we control when the
    patch gets applied. We can fix our software, then apply the patch,
    then fix our software some more, then push the fixes upstream, all
    on our own schedule.

  - **Future-Proofing.** Third-party dependencies are prone to
    vanishing. Companies get acqui-hired or go bankrupt. Hobbyists
    lose interest. People get sick or go on vacation. If you own the
    dependency, *you* control when it fails.

If building a box from scratch was a lot of work, we'd be tempted to
ignore these risks, as most people do. But thanks to
[Hashicorp's Packer](http://www.packer.io), it isn't a lot of work to
build a box from scratch... once you've got the tricky configuration
files written.

### How To Build A Distro Box

  1. `cd` into the appropriate `distros` subdirectory.
  2. Type `make`.
  3. Do something else for fifteen or twenty minutes while the box builds.
  4. The `.box` file is now sitting in your subdirectory.
  5. Type `make install` to add the box to your local machine.
  6. Alternatively, use `make upload` to send the box up to S3. You'll need an S3 account; see below.

## Publishing Boxes on Vagrant Cloud (Optional)

Once you've used these scripts to build a Vagrant box file on your
local machine, you can use `vagrant box add` to install it
locally. But it might also be convenient to push it up to
[Vagrant Cloud](https://vagrantcloud.com/hashicorp/precise64) where
other computers can see it, and other projects can refer to it by a
consistent name.

The problem with cloud-hosted box files, though, is that they can be
very slow to download. This is annoying enough when you're downloading
someone else's box and you have no other choice but to wait an hour
for the download to complete. But it is *infuriating* when you're
waiting for Vagrant to download a box file that *you just built on
your local machine and uploaded five minutes ago*, a file which is
*currently sitting on your hard drive*, but Vagrant Cloud doesn't know
it's there.

But if you want to get every machine and developer to use the exact
same Vagrant boxes -- either for maximum consistency, or to avoid the
need to rebuild boxes on every machine -- or if you want to share your
configured boxes with developers around the world, here's an outline
of the procedure:

  1. Create a
     [Vagrant Cloud](https://vagrantcloud.com/hashicorp/precise64)
     account.
     
  1. [Create an Amazon S3 account](http://aws.amazon.com/s3/), then
     create a bucket in S3 to host the `.box` files that you're going
     to publish on Vagrant Cloud.
  
  1. Install the
     [AWS Command Line Interface](http://aws.amazon.com/cli/). Test
     its configuration by typing `aws s3 ls` on a command line and
     seeing that a list of your buckets appears.

  1. Set the `CANNERY_BUCKET` environment variable to be the name
     of the S3 bucket where you'll store the `.box` files:
     `export CANNERY_BUCKET='my_bucket/my_boxes'`.
  
  1. `cd` into the subdirectory of `distros` where you built your box
     file, then type `make upload`. The uploader script will upload
     the box file. This may take a little while. Make a note of the URL
     (or look it up later using `aws s3 ls`).

  1. Log into Vagrant Cloud and publish your box. Use the
     "self-hosted" provider and give it the S3 URL which the uploader
     script told you about.

  1. The next time you build this box, instead of publishing a *new*
     box, publish a new *version* of the previous box, and your
     downloaders will be able to use Vagrant's upgrade feature to
     upgrade their local copies of your box.

To aid in publishing upgrades to a box, the uploader script
automatically adds the build timestamp to the name of the `.box` file
in S3. This allows you to follow good versioning practice:

  1. Leave the old version of the box available with version number,
     say, `0.1.3`.
  
  1. Publish the new version as `0.1.4`.
  
  1. Go to your projects and pull down the upgraded box using `vagrant
     box update`. Have your friends and coworkers do the same.
  
  1. If the new `0.1.4` box turns out to have some devastating bug,
     the old version `0.1.3` is still available and people can revert
     to it.

  1. Don't unpublish the old version of the `.box` file until it's at
     least two versions old and you're sure all the users are done
     with it. Remember: Storing 1GB on S3 costs 3 cents a month. It's
     barely worth the time to clean up.

