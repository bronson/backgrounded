## Backgrounded

Start something and gtfo.


## Features

* cross-platform
  * works with bash 3 and bash 4
  * avoids nonstandard commands like setsid, start-stop-daemon, and nohup.
* small, easy to understand, and well commented where it isn't.
* easy to embed in your project and use from the command line.


## Installation

Clone the repo.  Or download the script file if you want, it's just a single file.


## Usage

```bash
backgrounded 'echo $$: `date`; sleep 1'
```

This fires up the given command and detaches it from the terminal.
It also makes it the group leader so any subprocesses it starts will
be terminated too.  Since you didn't give the command a name, the
pidfile will be named `background.pid`.

You can check on it from time to time, or just stop it:

```bash
backgrounded status
backgrounded kill
```

You can run multiple processes if you give them a name.

```bash
backgrounded quick 'echo $$: `date`; sleep 0.5'
backgrounded slow 'echo $$: `date`; sleep 2'
backgrounded status slow
backgrounded kill quick slow
```

backgrounded logs to its stdout.  You can redirect its stdout to
your logfile if you want to keep it or to /dev/null if you don't.


http://stackoverflow.com/questions/20449707/using-travis-ci-for-testing-on-unix-shell-scripts

* `make test` (or just `make`)
* `make install` if you want to install in ~/bin (if it exists) or /usr/local/bin

I don't actually recommend installing it globally.  Instead, copy
the backgrounded script somewhere in your repository and run it
locally (something like `./backgrounded run ./my-script.sh`).
Don't worry about keeping it up to date...  if it's working for you,
why mess with it?


## Writing a Good Background Task

suggest CDing to $HOME so you don't hold any FDs on volumes that can be unmounted.

TODO: ensure STDIN/OUT/ERR are all redirected to files.

It probably makes sense to close other files before forking.
  close-fds() {
    eval exec {3..255}\>\&-
    }

http://blog.n01se.net/blog-n01se-net-p-145.html
