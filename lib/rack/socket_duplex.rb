require "socket"

module Rack
  class SocketDuplex
    VERSION = '1.0.0'

    def initialize(app, socket_path)
      @app, @socket_path = app, socket_path
    end

    def call(env)
      if env["rack.url_scheme"] == "http"
        UNIXSocket.open(@socket_path) do |socket|
          write_env socket, env
        end rescue nil
      end

      @app.call(env)
    end

    protected

    def write_env(socket, env)
      write_request_line socket, env
      write_headers      socket, env

      socket << "\r\n" # empty line

      write_post_body socket, env
    end

    def write_request_line(socket, env)
      path_with_query_string = env["PATH_INFO"]
      path_with_query_string << "?#{env["QUERY_STRING"]}" if env["QUERY_STRING"].length > 0

      socket << "#{env["REQUEST_METHOD"]} #{path_with_query_string} #{env["HTTP_VERSION"] || "HTTP/1.0"}\r\n"
    end

    def write_headers(socket, env)
      headers = env.select { |k, v| k =~ /^HTTP_|CONTENT_/ }
      headers.delete("HTTP_VERSION")
      
      headers.each do |k,v|
        socket << "#{k.gsub(/^HTTP_/, "").gsub("_", "-")}: #{v}\r\n"
      end
    end

    def write_post_body(socket, env)
      if env["CONTENT_LENGTH"] && (content_length = env["CONTENT_LENGTH"].to_i) > 0
        socket << env["rack.input"].read
        env["rack.input"].rewind
      end
    end
  end
end
