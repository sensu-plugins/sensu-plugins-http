#!/bin/sh
#
# Set up a super simple web server and make it accept GET and POST requests
# for Sensu plugin testing.
#

DATA_DIR=/tmp/kitchen/data
SENSU_DIR=/opt/sensu
GEM=$SENSU_DIR/embedded/bin/gem
RUBY=$SENSU_DIR/embedded/bin/ruby

if [ ! -d $SENSU_DIR ]; then
  wget -q http://repositories.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -
  echo "deb http://repositories.sensuapp.org/apt sensu main" | sudo tee /etc/apt/sources.list.d/sensu.list
  sudo apt-get update
  sudo apt-get install -y git vim nginx sensu
  sudo service nginx status || sudo service nginx start
  sudo rm /etc/nginx/sites-enabled/default
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
    }
  " | sudo tee /etc/nginx/sites-enabled/sensu-plugins-http.conf
  sudo service nginx restart
fi

cd $DATA_DIR
SIGN_GEM=false $GEM build sensu-plugins-http.gemspec
sudo sensu-install -p sensu-plugins-http-*.gem
