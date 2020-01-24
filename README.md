This project builds a Docker container from which you can use [`impala-shell.sh`](https://impala.apache.org/docs/build/html/topics/impala_impala_shell.html).

# Preflight

You will need:

  * [Docker](https://docs.docker.com/install/) (sorry!)

Now checkout a copy of the project with:

    git clone https://gitlab.com/jimdigriz/impala-shell.git

# Build

    docker build -t impala-shell -f .

# Usage

    docker run -it --name impala-shell impala-shell

Then inside the container, get your Kerberos token with:

    kinit bob@EXAMPLE.COM

Now you should be able to make your queries with:

    impala-shell.sh -i impala.example.com -k
