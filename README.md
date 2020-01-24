This project builds a Docker container from which you can use [`impala-shell.sh`](https://impala.apache.org/docs/build/html/topics/impala_impala_shell.html).

# Build

    docker build -t impala-shell -f .

# Usage

    docker run -it --name impala-shell impala-shell

Then inside the container, get your Kerberos token with:

    kinit bob@EXAMPLE.COM

Now you should be able to make your queries with:

    impala-shell.sh -i impala.example.com -k
