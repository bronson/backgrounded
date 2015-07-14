## Backgrounded [![Build Status](https://travis-ci.org/bronson/backgrounded.svg)](https://travis-ci.org/bronson/backgrounded)

Maintain your background tasks.  Launch and gtfo.


## Features

* full service: start tasks, stop them, and get their status.
* cross-platform
  * works with Bash 3 & 4 in any posix environment: Mac/Linux/BSD/etc.
  * avoids nonstandard commands like setsid, start-stop-daemon, and nohup.
* small, easy to understand, and well commented where it isn't.
* easy to embed in your project and use from the command line.


## Installation

Clone the repo.  Or just copy the script file into your project -- it's just a single file.


## Usage

```bash
backgrounded 'echo $$: `date`; sleep 1'
```

This starts the given command and detaches it from your session.
It also makes it the process group leader so any subprocesses it starts will
be terminated too.  Since you didn't give the command a name, the
pidfile will be named `background.pid`.

But why wasn't there any output??  Because it detached from your session.
The output disappeared into the void.
If you redirect to a file, you'll see it's alive and well.

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
backgrounded status lazytask
backgrounded kill rapidtask lazytask
```

backgrounded logs to its stdout.  You can redirect its stdout to
your logfile if you want to keep it or to /dev/null if you don't.


## Developing

* `make test` (or just `make`)


## Roadmap

* make tests individually runnable
* complete rename to backgrounded
* allow naming processes
* test killing children / process group
* test status command


## Writing a Good Background Task

suggest CDing to $HOME so you don't hold any FDs on volumes that can be unmounted.

TODO: ensure STDIN/OUT/ERR are all redirected to files.

It probably makes sense to close other files before forking.
  close-fds() {
    eval exec {3..255}\>\&-
    }

http://blog.n01se.net/blog-n01se-net-p-145.html
