This project builds a Docker container from which you can use [`impala-shell.sh`](https://impala.apache.org/docs/build/html/topics/impala_impala_shell.html).

# Preflight

You will need:

 * [Docker](https://docs.docker.com/install/) (sorry!)
 * Impala authentication handled by Kerberos
     * credentials for yourself to log in
 * about 20GiB of disk space

Now checkout a copy of the project with:

    git clone https://gitlab.com/jimdigriz/impala-shell.git

# Build

    docker build -t impala-shell .

This will take at *least* 30 minutes and will download a *lot* of content from the Internet.

# Usage

Start running the built container image with:

    docker run -it --rm --name impala-shell impala-shell

Now we authenticate ourselves to Kerberos from inside the container by running:

    kinit bob@EXAMPLE.COM

**N.B.** if this does not work, you can try `env KRB5_TRACE=/dev/stdout kinit ...`

To get a [REPL](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop) similar to `{sqlite3,mysql,psql}` you run:

    impala-shell -i impala.example.com

**N.B.** `impala-shell` is a wrapper script for `impala-shell.sh` to make things a little simpler and more transparent

You should be able to make queries via the CLI instead of the web frontend.

## Scripting

If you leave your container running after authenticating, you can from another terminal window make queries directly using:

    docker exec impala-shell impala-shell -i impala.example.com -q 'SELECT * FROM db.table WHERE YEAR = 2020 AND MONTH = 1 AND DAY = 24 LIMIT 1'

## Advanced

The wrapper script `impala-shell` does the following:

 * always adds `-k` to your parameters list so you do not need to
 * when running non-interactively (ie. in a script) then it always adds the parameters `--quiet --print_header -B`
     * `docker exec -it impala-shell ...` with the added `-it` makes the command interactive

If you wanted to run `impala-shell.sh` without the wrapper, you will want to adjust your incantation to resemble:

    docker exec impala-shell /bin/bash -lc 'impala-shell.sh -i impala.example.com -k --print_header -B -q "SELECT * FROM db.table WHERE YEAR = 2020 AND MONTH = 1 AND DAY = 24 LIMIT 1"'

The use of `bash -l` picks up `/etc/profile.d/impala-shell` so everything can work.
