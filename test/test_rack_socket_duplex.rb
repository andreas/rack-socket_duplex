require "test/unit"
require "rack"
require "rack/socket_duplex"

class Rack::SocketDuplexTest < Test::Unit::TestCase
  def setup
    @socket_path = "/tmp/rack-socket_duplex-test#{(rand*10000).to_i}"

    @vanilla_app = lambda { |env| [200, {}, ["Content"]] }
    @app         = Rack::SocketDuplex.new(@vanilla_app, @socket_path)

    @req         = Rack::MockRequest.new(@app)
    @vanilla_req = Rack::MockRequest.new(@vanilla_app)
  end

  # Helper methods

  def socket_content(&blk)
    content = nil

    UNIXServer.open(@socket_path) do |server|
      yield
      s = server.accept
      content = s.read
      s.close
    end

    content
  end

  def assert_equal_response(expected, actual)
    assert_equal expected.headers, actual.headers
    assert_equal expected.body, actual.body
  end

  def assert_equal_http(expected, actual)
    assert_match Regexp.new(Regexp.escape(expected), Regexp::IGNORECASE), actual
  end

  # Tests

  def test_doesnt_alter_get_response
    assert_equal_response @vanilla_req.get("/"), @req.get("/")
  end

  def test_doesnt_alter_post_response
    assert_equal_response @vanilla_req.post("/", input: "bla"),
                          @req.post("/", input: "bla")
  end

  def test_writes_get_request_to_socket
    assert_equal_http "GET / HTTP/1.0\r\nContent-Length: 0",
                      socket_content { @req.get("/") }
  end

  def test_writes_query_string_to_socket
    assert_match /^GET \/\?foo=bar/i, socket_content { @req.get("/?foo=bar") }
  end

  def test_writes_post_body_to_socket
    assert_equal_http "POST / HTTP/1.0\r\nContent-Length: 11\r\n\r\nfoo bar baz",
                      socket_content { @req.post("/", input: "foo bar baz") }
  end

  def test_writes_user_agent_header_to_socket
    assert_match /User\-Agent: foo/i,
                 socket_content { @req.get("/", "HTTP_USER_AGENT" => "foo") }
  end

  def test_writes_cookie_header_to_socket
    assert_match /Cookie: foo/i,
                 socket_content { @req.get("/", "HTTP_COOKIE" => "foo") }
  end

  def test_writes_accept_header_to_socket
    assert_match /Accept: text\/xml/i,
                 socket_content { @req.get("/", "HTTP_ACCEPT" => "text/xml") }
  end

  def test_writes_accept_charset_header_to_socket
    assert_match /Accept\-Charset: utf-8/i,
                 socket_content { @req.get("/", "HTTP_ACCEPT_CHARSET" => "utf-8") }
  end

  def test_writes_accept_encoding_header_to_socket
    assert_match /Accept\-Encoding: gzip/i,
                 socket_content { @req.get("/", "HTTP_ACCEPT_ENCODING" => "gzip") }
  end

  def test_writes_accept_language_header_to_socket
    assert_match /Accept\-Language: en\-US/i,
                 socket_content { @req.get("/", "HTTP_ACCEPT_LANGUAGE" => "en-US") }
  end

  def test_writes_cache_control_header_to_socket
    assert_match /Cache\-Control: no\-cache/i,
                 socket_content { @req.get("/", "HTTP_CACHE_CONTROL" => "no-cache") }
  end

  def test_writes_connection_header_to_socket
    assert_match /Connection: keep\-alive/i,
                 socket_content { @req.get("/", "HTTP_CONNECTION" => "keep-alive") }
  end

  def test_host_header_to_socket
    assert_match /Host: example.com/i,
                 socket_content { @req.get("/", "HTTP_HOST" => "example.com") }
  end

  def test_pragma_header_to_socket
    assert_match /Pragma: no\-cache/i,
                 socket_content { @req.get("/", "HTTP_PRAGMA" => "no-cache") }
  end
end
