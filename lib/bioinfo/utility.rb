#!/usr/bin/env ruby
# encoding: UTF-8
require 'singleton'
require "uri"
require "net/http"

# Utilities defined here to make Bioinfo namespace simple and tidy
module Bioinfo::Utility
  module_function

  # Set autoloaders for given context
  # @param [Hash] hash module-path pairs
  # @param [Module] context in which to set the autoloaders
  def set_autoloaders(hash, context)
    hash.each { |mod, path| context.autoload(mod, path) }
  end

  # Create the directory and make parent directories as needed
  # @param [String] dir target directory
  def mkdir_with_parents(dir)
    dirs = []
    until Dir.exists?(dir)
      dirs<<dir
      dir = File.dirname(dir)
      # raise "Directory too deep" if dirs.size > 64
    end

    dirs.reverse.each { |d| Dir.mkdir(d) }
  end

  # Get a timestamp string as a legal file name
  # @return [String]
  # @example
  #   Bioinfo::Utility.get_timestamp # => "20130830_175334"
  def get_timestamp
    Time.now.to_s.split(" ")[0..1].join("_").gsub(/-|:/,"")
  end

  # Options for network connection
  # @example
  #   Bioinfo.opt_network.timeout = 60 # 60 senconds
  #   
  NetworkOption = Struct.new(:timeout, :proxy) do
    include Singleton
  end

  # Error class representing HTTP errors
  class HTTPError < RuntimeError; end

  # Centralised request function for handling all of the HTTP requests.
  #
  # @param [String] url the url
  # @param [Hash] opts
  # @option opts [String] :method 'get' or 'post'
  # @option opts [String] :query a string
  # @option opts [Fixnum] :timeout override the default timeout in {Bioinfo.opt_network}
  #
  # @return [String] the response body
  #
  # @example
  #   request('http://www.example.com',   # the url
  #     {
  #       :method  => 'get',              # get/post
  #       :query   => 'a string',         # when using post, send this as 'query' (e.g. a query xml)
  #       :timeout => 60                  # override the default timeout
  #     })
  #
  # @raise Bioinfo::Utility::HTTPError Raised if a HTTP error was encountered
  def request(url, opts = { :method => 'get', :query => '', :timeout => nil })
    # Convert space into +
    url.gsub!(" ","+")

    # Parse the url
    uri = URI.parse( url )
    client = Net::HTTP
    if Bioinfo.opt_network.proxy
      proxy  = URI.parse( Bioinfo.opt_network.proxy )
      client = Net::HTTP::Proxy( proxy.host, proxy.port )
    end

    # Parse the method
    req = nil
    case opts[:method]
    when 'post'
      req           = Net::HTTP::Post.new(uri.path)
      req.form_data = { "query" => opts[:query] }
    else 'get'
      req           = Net::HTTP::Get.new(uri.request_uri)
    end

    # HTTP request
    response = nil
    client.start(uri.host, uri.port) do |http|
      if Bioinfo.opt_network.timeout || opts[:timeout]
        http.read_timeout = opts[:timeout] || Bioinfo.opt_network.timeout
        http.open_timeout = opts[:timeout] || Bioinfo.opt_network.timeout
      end
      response = http.request(req)
    end
    response_code = response.code
    response_body = response.body

    # Check encoding
    if defined? Encoding && response_body.encoding == Encoding::ASCII_8BIT
      response_body = response_body.force_encoding(Encoding::UTF_8)
    end

    # Check returned code
    response_code = response_code.to_i if response_code.is_a?(String)
    raise HTTPError, "HTTP error #{response_code}, please check your Internet connetion and URL settings." if response_code != 200

    return response_body
  end
end
