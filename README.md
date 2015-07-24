## Backgrounded [![Build Status](https://travis-ci.org/bronson/backgrounded.svg)](https://travis-ci.org/bronson/backgrounded)

Start something.  Launch and gtfo.  Daemonize all the things.

## Warning

The functionality all works but I'm not happy with the amount of complexity
caused by the argument parsing.  I'm going to take a machete to it, hopefully soon.

## Overview

This script makes it easy to start long-running process in the background
and ensures it continues to run unmolested.  It also makes it easy for you
to check on the long-running process or kill it.


### Features

* full service: start tasks, stop them, get their status.
* runs everywhere:
  * pure Bash 3 & 4 so it works in any posix environment: Mac/Linux/BSD/etc.
  * avoids poorly standardized commands like setsid, daemon, start-stop-daemon, and nohup.
* easy to embed in your project or use from the command line.


## Installation

Clone the repo.  Or just copy [the script](https://github.com/bronson/backgrounded/blob/master/bin/backgrounded)
into your project -- it's just a single file.


## Usage

```bash
backgrounded 'echo $$: `date`; sleep 1'
```

This starts the given command and detaches it from your session.
It also makes it the process group leader so any subprocesses it starts will
be terminated too.  Since you didn't give the command a name, the
pidfile will be named `background.pid` and all .

```bash
backgrounded 'echo $$: `date` >> /tmp/log; sleep 1'
```

You can check on the backgrounded command from time to time, or just stop it:

```bash
backgrounded status
backgrounded kill
```

You can run multiple processes if you give them a name.

```bash
backgrounded rapidtask 'echo $$: `date`; sleep 0.5'
backgrounded lazytask 'echo $$: `date`; sleep 2'
backgrounded status rapidtask lazytask
backgrounded stop rapidtask lazytask
```

backgrounded logs to its stdout.  You can redirect its stdout to
your logfile if you want to keep it or to /dev/null if you don't.


## The Task

When your task is run:

* stdin is from /dev/null
* both stdout and stderr go into the logfile
* (TODO needs testing) HUP and INT are ignored.
* It's the process group leader, so any forked processes are part of your group.


## Testing

* `make test` (or just `make`)

You can also run individual tests by launching them directly.

* `test/01-runnable_test.sh`
* `test/03-killable_children_test.sh`

This script uses [bashes](https://github.com/bronson/bashes)
to ensure the continuous integration tests both Bash 3 and Bash 4.


## Roadmap

* log starting and stopping events.  standardize logging.
* what about hup?  can the task handle hup?  (trap '' 1 2)  probably want to ignore INT.
* simplify script, 170 lines is too many
* allow caller to choose whether to kill existing processes, to block until they finish, or just to exit
* make it optional whether we fire up a login shell or not?
* make it possible to run kill with arbitrary signals.

## Writing a Good Background Task

* You probably want to cd to $HOME so you don't hold any FDs on volumes that can be unmounted.

* You probably want to close all files before forking: `eval exec {3..255}\>\&-`

* http://blog.n01se.net/blog-n01se-net-p-145.html

#### Process concurrency.

It seems like the pidfile should ensure that only a single background task will ever be running.
That's not completely true!  Thanks to Unix design, it's slightly racy.  As long as you're launching
background processes occasionally (for example, when deploying an application), this should be good enough.

If you have heavy contention, use a better locking technique like the
[flock command](http://stackoverflow.com/questions/169964/how-to-prevent-a-script-from-running-simultaneously).
If you run flock within your backgrounded task, you can be 100% certain that only a single copy can every be running at once.
But, as noted before, most projects won't need this sort of guarantee.
