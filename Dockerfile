FROM  ubuntu:16.04.3

MAINTAINER  keiranmraine@gmail.com

LABEL uk.ac.sanger.cgp="Cancer Genome Project, Wellcome Trust Sanger Institute" \
      version="2.0.3" \
      description="The CGP mapping pipeline for dockstore.org"

USER  root

ENV OPT /opt/wtsi-cgp
ENV PATH $OPT/bin:$PATH
ENV PERL5LIB $OPT/lib/perl5
ENV LD_LIBRARY_PATH $OPT/lib

RUN apt-get -yq update
RUN apt-get install -yq --no-install-recommends\
  apt-transport-https\
  curl\
  build-essential\
  libcurl4-openssl-dev\
  nettle-dev\
  libncurses5-dev\
  autoconf\
  libtool\
  rsync\
  libexpat1-dev\
  time\
  libgoogle-perftools-dev\

RUN mkdir -p $OPT/bin

ADD build/biobambam2-build.sh build/
RUN bash build/biobambam2-build.sh && \
 rsync -rl biobambam/bin $INST_PATH/. && \
 rsync -rl biobambam/include $INST_PATH/. && \
 rsync -rl biobambam/lib $INST_PATH/. && \
 rsync -rl biobambam/share $INST_PATH/. && \
 rm -rf biobambam

ADD build/opt-build.sh build/
RUN bash build/opt-build.sh $OPT

ADD scripts/mapping.sh $OPT/bin/mapping.sh
ADD scripts/ds-cgpmap.pl $OPT/bin/ds-cgpmap.pl
RUN chmod a+x $OPT/bin/mapping.sh $OPT/bin/ds-cgpmap.pl

## USER CONFIGURATION
RUN adduser --disabled-password --gecos '' ubuntu && chsh -s /bin/bash && mkdir -p /home/ubuntu

USER    ubuntu
WORKDIR /home/ubuntu

CMD ["/bin/bash"]
