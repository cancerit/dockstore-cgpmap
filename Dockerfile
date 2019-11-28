FROM  quay.io/wtsicgp/pcap-core:4.4.1

MAINTAINER  cgphelp@sanger.ac.uk

LABEL vendor="Cancer, Ageing and Somatic Mutation, Wellcome Trust Sanger Institute"
LABEL uk.ac.sanger.cgp.description="PCAP-core for dockstore.org"
LABEL uk.ac.sanger.cgp.version="3.2.0"

USER root

ADD scripts/mapping.sh $OPT/bin/mapping.sh
ADD scripts/ds-cgpmap.pl $OPT/bin/ds-cgpmap.pl
RUN chmod a+x $OPT/bin/mapping.sh $OPT/bin/ds-cgpmap.pl

USER ubuntu
WORKDIR /home/ubuntu

CMD ["/bin/bash"]
