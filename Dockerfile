FROM ubuntu:14.04

RUN apt-get update -q
RUN apt-get install -qy python-software-properties software-properties-common
RUN add-apt-repository -y ppa:brightbox/ruby-ng
RUN apt-get update -q

# 'noninteractive' will stop tty related warnings
RUN DEBIAN_FRONTEND=noninteractive apt-get install -qy nginx ruby2.1 ruby2.1-dev nodejs sqlite3 libsqlite3-dev zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt1-dev libcurl4-openssl-dev git-core curl

# mysql client libs
RUN DEBIAN_FRONTEND=noninteractive sudo apt-get install -qy mysql-client libmysqlclient-dev

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-enabled/default
RUN mkdir -p /var/www
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"

WORKDIR /tmp
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
RUN /bin/bash -l -c "bundle install"

# custom nginx/unicorn configuration and script start up script
ADD ./ /var/www/simple-app
ADD config/simple-app.conf /etc/nginx/sites-enabled/simple-app 
ADD config/start_server.sh /usr/bin/start_server
RUN chmod +x /usr/bin/start_server
RUN mkdir -p  /var/www/simple-app/tmp/pids
RUN mkdir -p  /var/www/simple-app/tmp/sockets
RUN mkdir -p  /var/www/simple-app/tmp/log

# used by Rails' config/secrets.yml
# obviously, this should not go here in a real world app
ENV SECRET_KEY_BASE 6cfe9ad62d67e58d3f380c2fe3d69edf3f31aaa6a1623f5ff5e7d31271e4070e17ec226a9cf230b6b2ec5559bce032033171ca7c8f5526afc0853bba6fc21078

WORKDIR /var/www/simple-app

EXPOSE 80

ENTRYPOINT /usr/bin/start_server
