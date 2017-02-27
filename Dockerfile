FROM  ubuntu:14.04

MAINTAINER  keiranmraine@gmail.com

LABEL uk.ac.sanger.cgp="Cancer Genome Project, Wellcome Trust Sanger Institute" \
      version="2.0.1" \
      description="The CGP mapping pipeline for dockstore.org"

USER  root

ENV OPT /opt/wtsi-cgp
ENV PATH $OPT/bin:$PATH
ENV PERL5LIB $OPT/lib/perl5
ENV LD_LIBRARY_PATH $OPT/lib

## USER CONFIGURATION
RUN adduser --disabled-password --gecos '' ubuntu && chsh -s /bin/bash && mkdir -p /home/ubuntu

RUN mkdir -p $OPT/bin

ADD scripts/mapping.sh $OPT/bin/mapping.sh
ADD scripts/ds-wrapper.pl $OPT/bin/ds-wrapper.pl
RUN chmod a+x $OPT/bin/mapping.sh $OPT/bin/ds-wrapper.pl

ADD build/apt-build.sh build/
RUN bash build/apt-build.sh

ADD build/perllib-build.sh build/
RUN bash build/perllib-build.sh

ADD build/opt-build.sh build/
ADD build/biobambam2-build.sh build/
RUN bash build/opt-build.sh $OPT

USER    ubuntu
WORKDIR /home/ubuntu

CMD ["/bin/bash"]
