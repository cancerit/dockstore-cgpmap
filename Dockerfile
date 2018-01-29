FROM  ubuntu:16.04 as builder

USER  root

ENV OPT /opt/wtsi-cgp
ENV PATH $OPT/bin:$PATH
ENV PERL5LIB $OPT/lib/perl5
ENV LD_LIBRARY_PATH $OPT/lib

RUN apt-get -yq update
RUN apt-get install -yq --no-install-recommends\
  apt-transport-https\
  curl\
  ca-certificates\
  libperlio-gzip-perl\
  make\
  bzip2\
  gcc\
  psmisc\
  time\
  zlib1g-dev\
  libbz2-dev\
  liblzma-dev\
  libcurl4-gnutls-dev\
  libncurses5-dev

RUN mkdir -p $OPT/bin

ADD build/opt-build.sh build/
RUN bash build/opt-build.sh $OPT

ADD scripts/mapping.sh $OPT/bin/mapping.sh
ADD scripts/ds-cgpmap.pl $OPT/bin/ds-cgpmap.pl
RUN chmod a+x $OPT/bin/mapping.sh $OPT/bin/ds-cgpmap.pl

FROM  ubuntu:16.04

MAINTAINER  keiranmraine@gmail.com

LABEL uk.ac.sanger.cgp="Cancer Genome Project, Wellcome Trust Sanger Institute" \
      version="2.0.3" \
      description="The CGP mapping pipeline for dockstore.org"

ENV OPT /opt/wtsi-cgp
ENV PATH $OPT/bin:$PATH
ENV PERL5LIB $OPT/lib/perl5
ENV LD_LIBRARY_PATH $OPT/lib

RUN apt-get -yq update
RUN apt-get install -yq --no-install-recommends\
  apt-transport-https\
  curl\
  ca-certificates\
  libperlio-gzip-perl\
  make\
  bzip2\
  gcc\
  psmisc\
  time\
  zlib1g\
  liblzma5\
  libncurses5

RUN mkdir -p $OPT
COPY --from=builder $OPT /opt/.

## USER CONFIGURATION
RUN adduser --disabled-password --gecos '' ubuntu && chsh -s /bin/bash && mkdir -p /home/ubuntu

USER    ubuntu
WORKDIR /home/ubuntu

CMD ["/bin/bash"]
