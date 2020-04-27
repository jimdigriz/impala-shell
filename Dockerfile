FROM ubuntu:bionic

ARG impala_version=3.4.0
ARG impala_sha512=a25d046ed469402a069df1cd2eec872b7a8fbde0e5f9da918ae9eeb3d152ceaa48f3df77a04e57f159bb4cb6f94301e3dc0ef516a39654da08a27fdf8b307fba

SHELL ["/usr/bin/nice", "-n", "19", "/usr/bin/ionice", "-c", "3", "/bin/sh", "-x", "-c"]

RUN export DEBIAN_FRONTEND=noninteractive \
	&& apt-get update \
	&& apt-get -yy --option=Dpkg::options::=--force-unsafe-io upgrade \
	&& apt-get -yy --option=Dpkg::options::=--force-unsafe-io install --no-install-recommends \
		ca-certificates \
		lsb-release \
		sudo \
		wget

RUN wget --content-disposition https://www.apache.org/dist/impala/${impala_version}/apache-impala-${impala_version}.tar.gz \
	&& printf "%s  %s\n" ${impala_sha512} apache-impala-${impala_version}.tar.gz \
		| sha512sum -c \
	&& tar xf apache-impala-${impala_version}.tar.gz \
	&& rm apache-impala-${impala_version}.tar.gz

ENV IMPALA_HOME=/apache-impala-${impala_version}

RUN sed -e '/buildall/ s/^/#/' $IMPALA_HOME/bin/bootstrap_build.sh | /bin/bash

RUN $IMPALA_HOME/buildall.sh -release -noclean -notests -cmake_only

RUN /bin/bash -c "source $IMPALA_HOME/bin/impala-config.sh && make -C $IMPALA_HOME -j$(($(getconf _NPROCESSORS_ONLN)+1)) shell_tarball" \
	&& mv /apache-impala-${impala_version}/shell/build/impala-shell-${impala_version}-RELEASE.tar.gz /impala-shell.tar.gz

FROM ubuntu:bionic

RUN export DEBIAN_FRONTEND=noninteractive \
	&& apt-get update \
	&& apt-get -yy --option=Dpkg::options::=--force-unsafe-io upgrade \
	&& apt-get -yy --option=Dpkg::options::=--force-unsafe-io install --no-install-recommends \
		krb5-user \
		libsasl2-2 \
		libsasl2-modules-gssapi-mit \
		locales \
		python \
	&& apt-get clean \
	&& find /var/lib/apt/lists -type f -delete

ENV LC_ALL=C.UTF-8

COPY --from=0 /impala-shell.tar.gz /

RUN tar -xf /impala-shell.tar.gz --transform='s~^\./[^/]*~opt/apache/impala~' \
	&& rm /impala-shell.tar.gz

COPY impala-shell /usr/local/bin/impala-shell

COPY krb5.conf /etc/krb5.conf

ENTRYPOINT ["/usr/local/bin/impala-shell"]
