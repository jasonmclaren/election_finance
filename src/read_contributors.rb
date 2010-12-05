#!/usr/bin/env ruby

require 'rubygems'
require 'hpricot'
require 'csv'

OUTPUT_FILENAME = "../contributors.csv"

# Scrape the actual individual contributor page
# doc is an html string
# returns a dict of full_name, city, province, postal_code
def parse_contributor_file(doc)
  full_name = doc.search("//span[@id='lblFullName']").inner_text
  city = doc.search("//span[@id='lblCity']").inner_text
  province = doc.search("//span[@id='lblProvince']").inner_text
  postal_code = doc.search("//span[@id='lblPostalCode']").inner_text
  return {:full_name => full_name, :city => city, :province => province, :postal_code => postal_code}
end

# returns a line of csv
def read_contributor_file(filename)
  doc = open(filename){|f| Hpricot(f)}
  contrib = get_contributor_info(doc)
  csv_line = CSV.generate_line(contrib.values)
end


def read_that_one_file
  output_csv = open(OUTPUT_FILENAME, "w+")
  csv_line = read_contributor_file("../contributor_pages/contributor1.aspx.html")
  output_csv.puts(csv_line)
  output_csv.close
  puts csv_line
end
