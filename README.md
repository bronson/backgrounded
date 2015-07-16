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


## Testing

* `make test` (or just `make`)

You can also run individual tests by launching them directly.

* `test/01-runnable_test.sh`
* `test/03-killable_children_test.sh`


## Roadmap

* test stale pidfiles
* test status command
* simplify script, 170 lines is too many
* allow caller to choose whether to kill existing processes, to block until they finish, or just to exit
* make it optional whether we fire up a login shell or not?
* make it possible to kill by sending an INT signal?


## Writing a Good Background Task

suggest CDing to $HOME so you don't hold any FDs on volumes that can be unmounted.

TODO: ensure STDIN/OUT/ERR are all redirected to files.

It probably makes sense to close other files before forking.
  close-fds() {
    eval exec {3..255}\>\&-
    }

http://blog.n01se.net/blog-n01se-net-p-145.html
