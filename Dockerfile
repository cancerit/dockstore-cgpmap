FROM  alpine:3.7

MAINTAINER  keiranmraine@gmail.com

LABEL uk.ac.sanger.cgp="Cancer Genome Project, Wellcome Trust Sanger Institute" \
      version="2.0.3" \
      description="The CGP mapping pipeline for dockstore.org"

USER  root

ENV OPT /opt/wtsi-cgp
ENV PATH $OPT/bin:$PATH
ENV PERL5LIB $OPT/lib/perl5
ENV LD_LIBRARY_PATH $OPT/lib

RUN apk update
RUN apk upgrade
RUN apk add --no-cache\
  autoconf\
  automake\
  bash\
  curl\
  file\
  g++\
  libc6-compat\
  libtool\
  make\
  musl-dev\
  rsync\
  zlib-dev\
  bzip2-dev\
  xz-dev\
  perl\
  perl-dev\
  curl-dev\
  openssl-dev\
  gnutls-dev\
  libtasn1-dev\
  nettle-dev\
  gmp-dev\
  p11-kit-dev\
  ncurses-dev

RUN mkdir -p $OPT/bin

ADD build/opt-build.sh build/
ADD build/biobambam2-build.sh build/
RUN bash build/opt-build.sh $OPT

ADD scripts/mapping.sh $OPT/bin/mapping.sh
ADD scripts/ds-cgpmap.pl $OPT/bin/ds-cgpmap.pl
RUN chmod a+x $OPT/bin/mapping.sh $OPT/bin/ds-cgpmap.pl

RUN addgroup -S cgp && adduser -G cgp -S cgp

USER cgp
WORKDIR /home/cgp

CMD ["/bin/bash"]
