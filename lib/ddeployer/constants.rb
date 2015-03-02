# coding: utf-8
module Ddeployer
  APP_SAVE_DIR = File.expand_path("~/.ddeployer")

  SERVER_YAML_SAMPLE = {
    'example' => {
      :host => 'localhost',
      :port => 2222,
      :user => 'vagrant',
      :key => {
        :path => '~/.vagrant.d/insecure_private_key',
        :passphrase => 'example'
      }
    },
    'example-pw' => {
      :host => 'example.com',
      :port => 2222,
      :user => 'user',
      :passwd => 'password'
    }
  }

  DDEPLOYER_YAML_SAMPLE = {
    'develop' => {
      :host_tag => 'example-pw',
      :path => {
        :local => './',
        :remote => '/var/www/html/example'
      }
    },
    'master' => {
      :host_tag => 'example',
      :path => {
        :local => './',
        :remote => '/var/www/html/example'
      }
    }
  }

end
