* cross-platform
  * works with bash 3 and bash 4
  * avoids nonstandard commands like setsid, start-stop-daemon, or nohup.
* small, easy to understand, and commented where it might not be.
* easy to embed in your project and also use from the command line.


The command logs to its stdout.  You can redirect its stdout to
your logfile if you want to keep it or to /dev/null if you don't.


http://stackoverflow.com/questions/20449707/using-travis-ci-for-testing-on-unix-shell-scripts

* `make test` (or just `make`)
* `make install` if you want to install in ~/bin (if it exists) or /usr/local/bin

I don't actually recommend installing it globally.  Instead, copy
the background-task script somewhere in your repository and run it
locally (something like `./background-task run ./my-script.sh`).
Don't worry about keeping it up to date...  if it's working for you,
then why mess with it?

## Writing a Good Background Task

suggest CDing to $HOME so you don't hold any FDs on volumes that can be unmounted.

TODO: ensure STDIN/OUT/ERR are all redirected to files.

It probably makes sense to close other files before forking.
  close-fds() {
    eval exec {3..255}\>\&-
    }

http://blog.n01se.net/blog-n01se-net-p-145.html
