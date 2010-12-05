#!/usr/bin/env ruby

require 'rubygems'
require 'hpricot'
require 'csv'
require 'open-uri'

INPUT_FILENAME = "../example_output/detail_report1.csv"
OUTPUT_FILENAME = "../contributors.csv"

# Scrape the actual individual contributor page
# doc is a Nokogiri XML doc
# returns a dict of full_name, city, province, postal_code
def parse_contributor_xml(doc)
  full_name = doc.search("//span[@id='lblFullName']").inner_text
  city = doc.search("//span[@id='lblCity']").inner_text
  province = doc.search("//span[@id='lblProvince']").inner_text
  postal_code = doc.search("//span[@id='lblPostalCode']").inner_text
  return {:full_name => full_name, :city => city, :province => province,
    :postal_code => postal_code}
end

# takes a contributor web page url or local html filename
# returns a line of csv, or nil if there is no contributor data in that page
def read_contributor_page(url)
  xml = open(url){|f| Hpricot(f)}
  contrib = parse_contributor_xml(xml)
  if contrib.values.reject{|v| v==""}.empty?
    return nil
  else
    CSV.generate_line([contrib[:full_name], contrib[:city], contrib[:province],
                       contrib[:postal_code]])
  end
end

# takes a csv file from the contribution scraper and a code block
# yields the client_number, row_number, and full_name
def all_contributors(contributions_filename, &block)
  CSV.open(contributions_filename, 'r') do |row|
    row_num, client_num, full_name = row[0], row[1], row[2]
    yield client_num, row_num, full_name
  end
end

def contributor_url(client_num, row_num)
  "http://elections.ca/scripts/webpep/fin2/contributor.aspx?type=1&client=#{client_num}&row=#{row_num}&seqno=&part=2a&entity=1&lang=e&option=4&return=2"
end

# takes a csv file of contributions (output of contributions.rb)
# writes (to stdout) a csv file of contributors in this format:
# client_num, row_num, full_name, city, province, postal_code
def fetch_all_contributors(contributions_filename)
  all_contributors(contributions_filename) do |client_num, row_num, full_name|
    line = read_contributor_page(contributor_url(client_num, row_num))
    if line.nil?
      puts "nil"
    else
      puts line
    end
  end
end
