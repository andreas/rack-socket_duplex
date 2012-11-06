# `rack-socket_duplex`

[http://github.com/andreas/rack-socket_duplex]()

## DESCRIPTION

`Rack::SocketDuplex` is Rack middleware that duplexes HTTP traffic to a unix socket. The primary use case is to subsequently forward this traffic to load test a new production environment (see **EXAMPLE** section).

## FEATURES/PROBLEMS

* Fairly low overhead (~5ms on small tests with a `em-proxy` server listening on the unix socket).
* Ignores SSL traffic.
* Converts Rack env to a raw HTTP request. The conversion tries to be accurate, but there might be discrepancies.

## SYNOPSIS

Add `Rack::SocketDuplex` as middleware in your `config.ru` or where appropriate:

    use Rack::SocketDuplex, "/tmp/rack-socket_duplex"

Use `netcat` or `em-proxy` to listen to the traffic, and forward it to a new production environment (load testing) or log it to a file.

To add `Rack::SocketDuplex` to Rails, add the following line to `config/application.rb` or a specific environment (e.g. `config/environments/development.rb`):

    config.middleware.use "Rack::SocketDuplex", "/tmp/rack-socket_duplex"

## EXAMPLE

See `examples/lobster.ru`. Run the example app with the following command:

    rackup lobster.ru -p 3000

Then open 127.0.0.1:3000 in a browser. To observe what's being written on the socket, run the following command:

    nc -klU /tmp/rack-socket_duplex-test

To forward the data other servers efficiently, use `forwarding-proxy` from the examples-folder (requries `em-proxy'):

    forwarding-proxy.rb /tmp/rack-socket_duplex-test example.com

## REQUIREMENTS

* Ruby 1.9
* Optional: `em-proxy`-gem to use `examples/forwarding-proxy`

## INSTALL

Add to bundler

    gem "rack-socket_duplex", git: "https://github.com/andreas/rack-socket_duplex"

or install as gem

    gem install rack-socket_duplex

## DEVELOPERS

After checking out the source, run:

    rake test

This task will run the tests/specs.

## LICENSE

(The MIT License)

Copyright (c) 2012 Andreas Garnæs

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
