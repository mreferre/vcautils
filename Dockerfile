FROM octohost/ruby-1.9.3p545
MAINTAINER massimo@it20.info

################## BEGIN INSTALLATION ######################

# Set the working directory to /root
WORKDIR /app

RUN git clone https://github.com/mreferre/vcautils.git /app/vcautils

WORKDIR /app/vcautils

ENV LANG=en_us.UTF-8
ENV LC_ALL=C.UTF-8

RUN gem build vcautils.gemspec 

RUN gem install vcautils-*.gem

##################### INSTALLATION END #####################

WORKDIR /app/vcautils/lib

EXPOSE 80

CMD /bin/sh -c "ruby vcaexplorer.rb -o 0.0.0.0 -p 80"


