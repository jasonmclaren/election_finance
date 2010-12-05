require 'rubygems'
require 'hpricot'
require 'nokogiri'
require 'pp'
require 'open-uri'
require 'read_contributors'
require 'json'

def parse_tabular_page(doc)
  rows = []
  table = doc.search("//table[@class='table_text']").first

  table.search('//tr').each{|tr|
    row = []
    tds = tr.search('//td')
    url = nil
    begin
      a = tds.first.search('//a').first
      unless a.nil?
        js = a[:href]
        match = js.match(/'(contributor.aspx?[^']+)'/)
        unless match.nil? || (link = match[1]).nil? || link.empty?
          #      http://elections.ca/scripts/webpep/fin2/contributor.aspx?type=1&client=15758&row=2566970&seqno=&part=2a&entity=1&lang=e&option=4&return=1
          url = "http://elections.ca/scripts/webpep/fin2/#{link}"
          #puts "grabbing #{url}"
          contributor_info = parse_contributor_file(Hpricot(open(url)))
          row << contributor_info.to_json
        end
      end
    rescue => e
      STDERR.puts e.message
    end unless tds.first.inner_text.nil? || tds.first.inner_text.empty?
  
    tds.each{|td|
      row << td.inner_text
    }
    #puts row.join(',')
    rows << row
    yield(row) if block_given?
  }
  return rows
end

if __FILE__ == $0
  file_name = "../list_pages/detail_report1.aspx.html"

  raise "Can't open #{file_name}" unless File.exists?(file_name)
  f = File.open(file_name)
  doc = Hpricot(f)
  f.close
  
  parse_tabular_page(doc){|row| puts row.join(",")}
end