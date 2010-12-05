require 'rubygems'
require 'hpricot'
require 'pp'
require 'cgi'
require 'csv'

def parse_tabular_page(doc, opts = {})
  rows = block_given? ? nil : []
  table = doc.search("//table[@class='table_text']").first
  
  trs = table.search('//tr')
  header_row = trs.delete_at(0)
  
  row = ['Row', 'Client']
  
  composite_elements = []
  
  header_row.search('//td').each_with_index{|td, index|
    element = td.inner_text
    elements = element.split(/ *\/ */)
    composite_elements[index] = elements.length
    row = row + elements
  }
  
  block_given? ? yield(row) : rows << row unless[:no_header]
  
  trs.each{|tr|
    row = []
    tds = tr.search('//td')
    url = nil
    begin
      a = tds.first.search('//a').first
      unless a.nil?
        js = a[:href]
        match = js.match(/'(contributor.aspx?[^']+)'/)
        unless match.nil? || (link = match[1]).nil? || link.empty?
          params = CGI::parse(link.split('?').last)
          client_id = Integer(CGI::unescape(params['client'].to_s))
          row_id    = Integer(CGI::unescape(params['row'].to_s))

          row << row_id
          row << client_id
        end
      end
    rescue => e
      STDERR.puts e.message
      row << nil
      row << nil
    end unless tds.first.inner_text.nil? || tds.first.inner_text.empty?
  
    tds.each_with_index{|td, index|
      element = td.inner_text
      if composite_elements[index] > 1
        elements = element.split(/ *\/ */)
        if elements.length == composite_elements[index]
          row = row + elements
        elsif elements.length < composite_elements[index]
          row = row + elements + Array.new(composite_elements[index] - elements.length, nil)
        else
          row = row + elements[0, composite_elements[index] - 1] + [elements[composite_elements[index]-1..-1].join(' / ')]
        end
      else
        row << element
      end
    }
    block_given? ? yield(row) : rows << row
  }
  return rows
end

if __FILE__ == $0
  file_name = "../list_pages/detail_report1.aspx.html"

  raise "Can't open #{file_name}" unless File.exists?(file_name)
  f = File.open(file_name)
  doc = Hpricot(f)
  f.close
  
  parse_tabular_page(doc){|row| puts CSV.generate_line(row)}
end