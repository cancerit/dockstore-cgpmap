FROM  quay.io/wtsicgp/pcap-core:5.3.0

LABEL vendor="Cancer, Ageing and Somatic Mutation, Wellcome Trust Sanger Institute"
LABEL maintainer="cgphelp@sanger.ac.uk"
LABEL uk.ac.sanger.cgp.description="PCAP-core for dockstore.org"
LABEL uk.ac.sanger.cgp.version="3.2.0"

USER root

ADD scripts/mapping.sh $OPT/bin/mapping.sh
ADD scripts/ds-cgpmap.pl $OPT/bin/ds-cgpmap.pl
RUN chmod +rx $OPT/bin/mapping.sh $OPT/bin/ds-cgpmap.pl

USER ubuntu
WORKDIR /home/ubuntu

CMD ["/bin/bash"]
