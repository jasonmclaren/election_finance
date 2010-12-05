#!/usr/bin/env ruby

require 'rubygems'
require 'curb'

# substitute a number like 2566970 for ROWNUM
# substitute a number like 16204 for CLIENTNUM
URL="http://elections.ca/scripts/webpep/fin2/contributor.aspx?type=1&client=CLIENTNUMrow=ROWNUM&seqno=&part=2a&entity=1&lang=e&option=4&return=2"

def fetch_page(url)
  
end
