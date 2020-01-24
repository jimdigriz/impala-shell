FROM ubuntu:bionic

SHELL ["/bin/sh", "-x", "-c"]

# clean later
RUN export DEBIAN_FRONTEND=noninteractive \
	&& apt-get update \
	&& apt-get -yy --option=Dpkg::options::=--force-unsafe-io upgrade \
	&& apt-get -yy --option=Dpkg::options::=--force-unsafe-io install --no-install-recommends \
		ca-certificates \
		krb5-user \
		libsasl2-modules-gssapi-mit \
		lsb-release \
		sudo \
		wget \
		xxd

RUN wget --content-disposition \
		https://www.apache.org/dist/impala/3.3.0/apache-impala-3.3.0.tar.gz \
		https://www.apache.org/dist/impala/3.3.0/apache-impala-3.3.0.tar.gz.sha512 \
	&& sha512sum -c apache-impala-3.3.0.tar.gz.sha512 \
	&& tar xf apache-impala-3.3.0.tar.gz \
	&& rm apache-impala-3.3.0.tar.gz apache-impala-3.3.0.tar.gz.sha512

RUN cd apache-impala-3.3.0 \
	&& export IMPALA_HOME=$(pwd) \
	&& sed -ie '/buildall/ s/^/#/' bin/bootstrap_build.sh \
	&& ./bin/bootstrap_build.sh \
	&& sed -ie '/buildall/ s/^#//' bin/bootstrap_build.sh

RUN apt-get clean \
	&& find /var/lib/apt/lists -type f -delete

RUN cd apache-impala-3.3.0 \
	&& export IMPALA_HOME=$(pwd) \
	&& ./buildall.sh -noclean -notests -skiptests

COPY init /init

ENTRYPOINT ["/init"]