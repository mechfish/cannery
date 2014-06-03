# Ruby-flavored Vagrant dev box

  - Ansible-based configuration.
  - Ruby 2.1 installed from the [Brightbox package repo](http://brightbox.com/docs/ruby/ubuntu/).
  - Node.js as the JS engine, installed from the [Chris Lea package repo](http://www.ubuntuupdates.org/ppa/chris_lea_nodejs).
  - PostgreSQL, with setup script to create default DBs with the proper locale.
  - Handy Rails bash aliases.
  - A bunch of Rails 4.1 gems preinstalled for greater speed.

Because this box uses Ruby 2.1 from an Ubuntu package, gems are
installed using `sudo gem install`. Bundler, which is preinstalled,
handles this automatically, so don't use `sudo` when running
Bundler. (Bundler will actually complain at you when you try, which
just goes to show that Bundler is well built.)

## Why is Ruby being installed from an Ubuntu package?

Once upon a time, there were a dozen legitimate production versions of
Ruby, and no Vagrant to help. So, clever people developed tools like
RVM and rbenv so that they could use multiple Ruby versions on their
development Macbooks.

Meanwhile, the stock Debian Ruby packaging is weird and has always been
weird. You kinda don't want to install Ruby using packages from the
Debian or Ubuntu package repositories.

The result is that lots of people have gotten into the habit of using
tools like RVM to install Ruby in *production*. This is not a
disaster, but that doesn't make it a good idea. You should install
Ruby from an OS package. You should install *everything* in production
from an OS package. Why?

  - Because ops people will give you a knowing nod when you tell them
    that you're doing it right.

  - Because, while Debian package semantics can be irritating, they
    are inescapable if you're the admin of a Debian system. But at
    least you can avoid having to deal with *other* kinds of
    "packaging" as well as Debian's.

  - Because any compilations you do on a production box while you're
    setting it up are slow, so your launches will be slow.

  - Because compiling requires a jumble of additional compile-time
    dependencies, like the C compiler and a double handful of header
    files, whose versions you probably don't have pinned. So every
    compile is slightly different from the last one. If your
    production box suddenly burst into flames, could you reproduce the
    exact Ruby binary that was running on that box? If you've
    installed from a Debian binary package the answer is consistently
    "yes".

  - Because Debian packages have a standard mechanism for representing
    and resolving dependencies on other Debian packages. Random Git
    checkouts have no idea what their environment is, let alone if it
    meets their requirements.

  - Because Ubuntu not only has cryptographic signatures on its
    packages, but actually uses them.

  - Because installing a `.deb` from a third-party repository takes about
    five lines of Ansible. It's squarely in the center of a
    configuration manager's sweet spot. Installing RVM, compiling
    Rubies, and making sure the paths and `ENV` vars are set correctly
    in your apps and cron jobs is a lot more work.

### The Ideal Strategy That We Aren't Using

The best general strategy is to build your *own* Ubuntu package for
Ruby or any other critical portion of your production stack. That way
you can rebuild it yourself five minutes after a zero-day patch hits
the official source tree, and push the patch live five minutes after
that. There's never an embarrassing moment where your boss is on the
phone, nagging an unpaid open-source developer to get out of bed and
rebuild your critical Ubuntu package for you.

If you actually want to take the trouble to be this awesome, you
should check out [FPM](https://github.com/jordansissel/fpm). If that
doesn't work you should learn the gentle art of taking somebody else's
existing `.deb` source package, stuffing a newer version of the code
into it, changing the version number, and rebuilding. Then you have to
figure out how to
[host your own Ubuntu package repo in S3](https://github.com/krobertson/deb-s3)
or something.

### The Lazy Person's Strategy That We Are Using

Because I'm not a full-time ops engineer I don't have the energy to
build my own packages. Instead I use
[Brightbox's packages](http://brightbox.com/docs/ruby/ubuntu/) and
[Chris Lea's packages](http://www.ubuntuupdates.org/ppa/chris_lea_nodejs). Thank
you for doing all this work for me! I promise not to nag you if it
takes you a whole day to update the packages I get from you for free.

## But couldn't we use RVM in development only?

We could. And there are reasons to do so, sometimes (e.g. "I am
working on a gem that should support two dozen different Ruby
binaries"). But in general I'd rather make my development Vagrant box
run the same Ruby packages as my production boxes. It saves wear and
tear on the brain. Why master two methods for installing Ruby when one
will do?


## But I run a production box with six different Ruby versions on it.

Don't do that! You should buy smaller VMs, so that you can run one
Ruby version per VM.

Perhaps most of your apps have no traffic, so you'd rather have them
share RAM? That sounds like a job for Heroku. Apps with no traffic
don't cost much to run on Heroku.

If your customers can't afford separate VMs, let alone Heroku, and you
*still* have to support several Ruby versions in a single VM, it's
likely that using RVM in production is the least of your problems. Or
maybe you're one of the few people with an actual use case for running
[Docker](https://www.docker.io) in production.


