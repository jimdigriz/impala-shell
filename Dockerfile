FROM ubuntu:bionic

ARG impala_version=3.3.0
ARG impala_sha512=71dcbb09c3d9d192f87f5031051331cf14a94f1162841b10e014917256b2212808fa5f576ea29a4b9bb3a0f8b7682910561158d69cb5d501c56587fd2844396b

SHELL ["/usr/bin/nice", "-n", "19", "/usr/bin/ionice", "-c", "3", "/bin/sh", "-x", "-c"]

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

RUN wget --content-disposition https://www.apache.org/dist/impala/${impala_version}/apache-impala-${impala_version}.tar.gz \
	&& printf "%s  %s\n" ${impala_sha512} apache-impala-${impala_version}.tar.gz \
		| sha512sum -c \
	&& tar xf apache-impala-${impala_version}.tar.gz \
	&& rm apache-impala-${impala_version}.tar.gz

RUN cd apache-impala-${impala_version} \
	&& export IMPALA_HOME=$(pwd) \
	&& sed -ie '/buildall/ s/^/#/' bin/bootstrap_build.sh \
	&& ./bin/bootstrap_build.sh \
	&& sed -ie '/buildall/ s/^#//' bin/bootstrap_build.sh

RUN apt-get clean \
	&& find /var/lib/apt/lists -type f -delete

RUN cd apache-impala-${impala_version} \
	&& export IMPALA_HOME=$(pwd) \
	&& ./buildall.sh -noclean -notests -skiptests

COPY profile.sh /etc/profile.d/impala-shell.sh
COPY impala-shell /usr/local/bin/impala-shell
RUN /bin/sh -c "sed -i -e 's/VERSION/${impala_version}/g' /etc/profile.d/impala-shell.sh /usr/local/bin/impala-shell"

COPY krb5.conf /etc/krb5.conf

CMD ["/bin/bash", "-l"]
