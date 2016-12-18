[![Build Status](https://travis-ci.org/meschbach/cloud-nginx-proxy.svg?branch=master)](https://travis-ci.org/meschbach/cloud-nginx-proxy)

# Cloud NGINX Proxy

An application designed to handle automatic _Nginx_ configuration updates, including reverse proxying.

## How it works

This application listens for changes in a specific subtree of your `etcd` instance.  When a change occurs, this application generates a configuration based on the set of `etcd` keys.  Once the configuration has been generated it then writes to an `etcd` key to restart Nginx.

## Installation and usage
In the future I hope to make this section more digestable.

### Dependencies
You require the following applciations to be installed:
* [Nginx](http://nginx.org/)
* [`etcd` 2](https://github.com/coreos/etcd/releases/tag/v2.3.7)

Please note: `etcd` 3 changed it's storage space to a key-value style and isn't compatiable.  Looking into it is as far as I have gotten; I might add a pluggable storage engine or drop `etcd` in favor of another storage like CouchDB.  If you have a horse in that race and are willing to get your hands dirty please feel free to let me know and dig in!

* [Ruby](https://www.ruby-lang.org/en/)

This project uses the `.ruby-version`.  In the future I might convert part of the project into a library.
For now any version of ruby greater than 2.0.0 should work, but I use the project with `.ruby-version`

* Client Application

This one is on you.  Just write the correct keys in the `etcd` path and you are good!

## Contributions

They are welcome!  Please open a pull request.

