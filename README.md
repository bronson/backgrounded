## Backgrounded [![Build Status](https://travis-ci.org/bronson/backgrounded.svg)](https://travis-ci.org/bronson/backgrounded)

Start something.  Launch and gtfo.  Daemonize all the things.


## Warning

This project may or may not be finished.  We'll see.


## Overview

This script makes it easy to start long-running processes in the background
and ensures they continue to run unmolested.  It also makes it easy
to check on them and kill them.


### Features

* full service: start tasks, stop them, get their status.
* runs everywhere.
  * pure Bash 3 & 4 so it works in any posix environment: Mac/Linux/BSD/etc.
  * avoids poorly standardized commands like setsid, daemon, start-stop-daemon, and nohup.
* easy to embed in your project or use from the command line.


## Installation

Clone the repo.  Or just copy [the script](https://github.com/bronson/backgrounded/blob/master/bin/backgrounded)
into your project -- it's just a single file.


## Usage

Backgrounded starts the command you specify and detaches it from your session.
It also makes it the process group leader so all subprocesses will
be terminated when it exits.  Everything should be cleaned up.

### Simple

If you only give backgrounded a command, it uses files named backgrounded-task.log and
backgrounded-task.pid in the current directory.

```bash
backgrounded 'echo $$: `date`; sleep 10; echo $$: `date`'
backgrounded status
# backgrounded-task.pid is running: 28490
backgrounded kill
```

### Named

You can run multiple processes simultaneously if you give each one a name.

```bash
backgrounded rapidtask 'echo $$; sleep 20'
backgrounded lazytask 'echo $$; sleep 20'
# now rapidtask.pid and lazytask.pid exist (and rapidtask.log/lazytask.log)
backgrounded status --quiet lazytask && echo 'lazy is still running'
backgrounded kill rapidtask
backgrounded kill lazytask
```

### Explicit

For full control, just tell backgrounded which files you'd like to use:

```bash
backgrounded \
    --logfile=/var/log/rapidtask.log \
    --pidfile=/var/run/rapidtask.pid \
    'echo $$; sleep 20'
```

Or a combination:

```bash
cd /var/run
backgrounded rapidtask --logfile=/var/log/rapidtask.log 'echo $$; sleep 20'
# pid is in /var/run/rapidtask.pid
```

### Arguments

* -p FILE / --pidfile=FILE: specify the pidfile to use.  If you do this, then supplying a name is unnecessary.
* -o FILE / --logfile=FILE: specify a file to receive your command's standard output and error, or `-o /dev/null` to ignore it.
* -q --quiet: produce as little output as possible.


## The Task

When your task is run:

* if a task was already running (as determined by the pidfile), that task is terminated before the new one is launched.
* stdin is from /dev/null
* both stdout and stderr go into the logfile
* (TODO needs testing) HUP and INT are ignored.
* it sets the process group leader, so any forked processes are part of your group and will be killed together.


## Testing

* `make test` (or just `make`)

You can also run individual tests by launching them directly.

* `test/01-runnable_test.sh`
* `test/03-killable_children_test.sh`

This script uses [bashes](https://github.com/bronson/bashes)
to ensure the continuous integration tests both Bash 3 and Bash 4.


## Roadmap

* watch for pidfile while waiting after sending kill command.  if it disappears, return immediately.
* offer two modes: replace running task, and print error if already running
  * allow caller to choose whether to kill existing processes, to block until they finish, or just to exit
* document that the pidfile is for the babysitter.  is there a way to get the pid of the actual child process?
* make it optional whether we fire up a login shell or not?
* what about hup?  can the task handle hup?  (trap '' 1 2)  probably want to ignore INT.


## Writing a Good Background Task

* You probably want to cd to $HOME so you don't hold any FDs on volumes that can be unmounted.

* You probably want to close all files before forking: `eval exec {3..255}\>\&-`

* http://blog.n01se.net/blog-n01se-net-p-145.html


#### Process concurrency.

It seems like the pidfile should ensure that only a single background task will ever be running.
That's not completely true!  Thanks to Unix design, it's slightly racy.  As long as you're launching
background processes occasionally (for example, when deploying an application), this should be good enough.

If you have heavy contention, or two copies running simulatenously would be catastrophic, use a better locking technique.
The [flock command](http://stackoverflow.com/questions/169964/how-to-prevent-a-script-from-running-simultaneously) is probably best,
but it's nonstandard and poorly deployed.  (todo: show an example)
