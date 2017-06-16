#!/bin/bash
#
# Set up a super simple web server and make it accept GET and POST requests
# for Sensu plugin testing.
#

set -e

source /etc/profile
DATA_DIR=/tmp/kitchen/data
RUBY_HOME=${MY_RUBY_HOME:-/opt/sensu/embedded}

if [ "$RUBY_HOME" = "/opt/sensu/embedded" ] && [ ! -d $RUBY_HOME ]; then
  wget -q http://repositories.sensuapp.org/apt/pubkey.gpg -O- | apt-key add -
  echo "deb http://repositories.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list
  apt-get update
  apt-get install -y sensu
else
  apt-get update
fi

apt-get install -y nginx build-essential
service nginx status || service nginx start
rm /etc/nginx/sites-enabled/default
echo "
  server {
    listen 80;

    location /okay {
      limit_except GET {
        deny all;
      }
      return 200;
    }

    location /notthere {
      limit_except GET {
        deny all;
      }
      return 404;
    }

    location /ohno {
      limit_except GET {
        deny all;
      }
      return 500;
    }

    location /gooverthere {
       limit_except GET {
         deny all;
       }
       return 301;
    }

    location /postthingshere {
      return 200;
    }

    location /json/okay {
      limit_except GET {
        deny all;
      }
      return 200 '{\"errors\":null}';
    }

    location /json/metric {
      limit_except GET {
        deny all;
      }
      return 200 '{\"count\":5}';
    }
  }
" > /etc/nginx/sites-enabled/sensu-plugins-http.conf
service nginx restart

cd $DATA_DIR
SIGN_GEM=false $RUBY_HOME/bin/gem build sensu-plugins-http.gemspec
$RUBY_HOME/bin/gem install sensu-plugins-http-*.gem
