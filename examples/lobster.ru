# Run me with:
#   $ rackup examples/lobster.ru -p 3000
#
# Then open 127.0.0.1:3000 in a browser.
#
# To observe what's being written on the socket, run the following command:
#   $ nc -klU /tmp/rack-socket_duplex-test
#
# To forward the data other backends, use forwarding-proxy.rb (requries em-proxy):
#   $ forwarding-proxy.rb /tmp/rack-socket_duplex-test example.com
#

require "pathname"
require "rack"
require "rack/lobster"

$:.unshift(Pathname(__FILE__).dirname.parent + "lib")
require "rack/socket_duplex"

use Rack::SocketDuplex, "/tmp/rack-socket_duplex-test"

run Rack::Lobster.new
