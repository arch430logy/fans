# frozen_string_literal: true

require_relative "fans/version"
require 'http'
require 'nokogiri'

module Fans
  class Fetcher
    attr_reader :url_to_name, :url_to_id, :url_to_html, :id_relations
  
    def initialize
      @url_id = 0
      @url_to_name = {}
      @url_to_id = Hash.new{|h, k| h[k] = (@url_id += 1)}
      @id_relations = Hash.new{|h, from| h[from] = Hash.new{|h, to| h[to] = Set.new}}
    end
  
    def page_by_id(id)
      if !@id_to_page || @id_to_page.size != url_to_id.size
        @id_to_page = url_to_id.invert
      end
      @id_to_page[id]
    end
  
    def fetch(url)
      uri = URI.parse(url)
      host = "#{uri.scheme}://#{uri.host}"
  
      from_id = url_to_id[url]
      html = url_to_html(url)
  
      html.css('a').each do |a|
        to_page = a.attributes['href']&.value
        next unless to_page
        to_page = File.join(host, to_page) if to_page.start_with?('/')
        to_id = url_to_id[to_page]
        text = a.text.strip.gsub(/\s+/, "\s")
        text = a.attributes['title']&.value&.gsub(/\s+/, "\s") if text.empty?
        id_relations[from_id][to_id] << text
      end
    end

    def local_sitemap(url)
      uri = URI.parse(url)
      host = "#{uri.scheme}://#{uri.host}"

      next_url = url
      while next_url
        next_url = _local_sitemap(next_url) do |a|
          link = a.attributes['href']&.value
          link = File.join(host, link) if link.start_with?('/')
          url_to_name[link] = a.text.strip.gsub(/\s+/, "\s")
          url_to_id[link]
        end
      end
    end

    private

    def _local_sitemap(url)
      uri = URI.parse(url)
      host = "#{uri.scheme}://#{uri.host}"

      html = url_to_html(url)

      html.css('.mw-allpages-chunk a').each do |a|
        yield a
      end

      a = html.at_css('.mw-allpages-nav a:last-child')
      text = a.text.strip.gsub(/\s+/, "\s")
      return unless text.start_with?('Next page')

      link = a.attributes['href']&.value
      link = File.join(host, link) if link.start_with?('/')
      link
    end

    def url_to_html(url)
      Nokogiri::HTML(HTTP.get(url).body.to_s)
    end
  end
end
