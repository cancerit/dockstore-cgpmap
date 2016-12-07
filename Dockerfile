FROM  ubuntu:16.04

MAINTAINER  keiranmraine@gmail.com

ARG cgpbox_ver=develop

LABEL uk.ac.sanger.cgp="Cancer Genome Project, Wellcome Trust Sanger Institute" \
      version="$cgpbox_ver" \
      description="The CGP somatic calling pipeline 'in-a-box'"

USER  root

ENV CGPBOX_VERSION $cgpbox_ver
ENV OPT /opt/wtsi-cgp
ENV PATH $OPT/bin:$PATH
ENV PERL5LIB $OPT/lib/perl5

## USER CONFIGURATION
RUN adduser --disabled-password --gecos '' ubuntu && chsh -s /bin/bash && mkdir -p /home/ubuntu

RUN mkdir -p $OPT/bin

ADD scripts/mapping.sh $OPT/bin/mapping.sh
RUN chmod a+x $OPT/bin/mapping.sh

ADD build/apt-build.sh build/
#ADD build/perllib-build.sh build/
ADD build/opt-build.sh build/

RUN bash build/apt-build.sh
#RUN bash build/perllib-build.sh
RUN bash build/opt-build.sh

USER    ubuntu
WORKDIR /home/ubuntu
#RUN     echo "options(bitmapType='cairo')" > /home/ubuntu/.Rprofile

ENTRYPOINT /bin/bash
