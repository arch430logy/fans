# frozen_string_literal: true

require_relative "fans/version"
require 'http'
require 'nokogiri'

module Fans
  class Fetcher
    attr_reader :pages, :links
  
    def initialize
      @page_id = 0
      @pages = Hash.new{|h, k| h[k] = (@page_id += 1)}
      @links = Hash.new{|h, from| h[from] = Hash.new{|h, to| h[to] = Set.new}}
    end
  
    def page_by_id(id)
      if !@id_to_page || @id_to_page.size != pages.size
        @id_to_page = pages.invert
      end
      @id_to_page[id]
    end
  
    def fetch(url)
      uri = URI.parse(url)
      host = "#{uri.scheme}://#{uri.host}"
  
      from_id = pages[url]
      resp = HTTP.get(url)
      html = Nokogiri::HTML(resp.body.to_s)
  
      html.css('a').each do |a|
        to_page = a.attributes['href']&.value
        next unless to_page
        to_page = File.join(host, to_page) if to_page.start_with?('/')
        to_id = pages[to_page]
        text = a.text.strip.gsub(/\s+/, "\s")
        text = a.attributes['title']&.value&.gsub(/\s+/, "\s") if text.empty?
        links[from_id][to_id] << text
      end
    end
  end
end
