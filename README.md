This project builds a Docker container from which you can use [`impala-shell`](https://impala.apache.org/docs/build/html/topics/impala_impala_shell.html).

# Preflight

You will need to have installed [Docker](https://docs.docker.com/install/).

# Usage

Start running the built container image with:

    docker run -it --rm jimdigriz/impala-shell

This will drop you straight into a CLI [REPL](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop) similar to `{sqlite3,mysql,psql}`.

If you want to use this from a script, you may find the following form useful to run queries directly:

    docker run --rm jimdigriz/impala-shell -i impala.example.com -q 'SELECT 1 AS test'

## Kerberos

Before using the REPL, you will need to authenticate to Kerberos from your own workstations (`apt-get install krb5-user`):

    env KRB5CCNAME=DIR:.krb5cc kinit bob@EXAMPLE.COM

Now use the REPL instead via:

    docker run -it --rm --env KRB5CCNAME=DIR:/tmp/krb5cc -v $(pwd)/.krb5cc:/tmp/krb5cc jimdigriz/impala-shell

# Build

Make sure you have above 15GiB of disk space free avaliable to Docker (`df -h /var/lib/docker`) and then checkout a copy of the project with:

    git clone https://gitlab.com/jimdigriz/impala-shell.git
    cd impala-shell

Now build the container, which will take 20 minutes on a 50Mbps Internet connection; most of that time is spent in downloading content:

    docker build -t impala-shell .

## Deploy

To push up to Docker Hub:

    docker tag impala-shell:latest jimdigriz/impala-shell:latest
    docker push jimdigriz/impala-shell:latest
