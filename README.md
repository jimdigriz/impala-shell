This project builds a Docker container from which you can use [`impala-shell.sh`](https://impala.apache.org/docs/build/html/topics/impala_impala_shell.html).

# Preflight

You will need:

 * [Docker](https://docs.docker.com/install/) (sorry!)
 * Impala authentication handled by Kerberos
     * credentials for yourself to log in

# Usage

Start running the built container image with:

    docker run -it --rm --name jimdigriz/impala-shell

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

# Build

You will need:

 * about 15GiB of disk space (in your Docker mount point)

Checkout a copy of the project with:

    git clone https://gitlab.com/jimdigriz/impala-shell.git
    cd impala-shell

Now build the container, which will take 20 minutes on a 50Mbps Internet connection; most of that time is spent in downloading content:

    docker build -t impala-shell .

## Deploy

To push up to Docker Hub:

    docker tag impala-shell:latest jimdigriz/impala-shell:latest
    docker push jimdigriz/impala-shell:latest
