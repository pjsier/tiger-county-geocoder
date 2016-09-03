#***********************************************************************************
#
# All code (C) Pete Warden, 2011
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#***********************************************************************************

require 'rubygems'
require 'json'

# A horrible hack to work around my problems getting the Geocoder to install as a gem
$LOAD_PATH.unshift '/geocoder/lib'
require 'geocoder/us/database'
$geocoder_db = Geocoder::US::Database.new '/geocoder/data/geocode.db', {:debug => true}

S2C_WHITESPACE = '(([ \t.,;]+)|^|$)'

# Takes an array of postal addresses as input, and looks up their locations using
# data from the US census
def street2coordinates(addresses)

  output = {}
  addresses.each do |address|
    begin
      info = geocode_us_address(address)
    #rescue
      #printf(STDERR, $!.inspect + $@.inspect + "\n")
      #info = nil
    end
    output[address] = info
  end

  return output

end

# Does the actual conversion of the US address string into coordinates
def geocode_us_address(address)

  country_names = '(U\.?S\.?A?\.?|United States|America)'
  country_names_suffix_re = Regexp.new(S2C_WHITESPACE+country_names+S2C_WHITESPACE+'?$', Regexp::IGNORECASE)
  countryless_address = address.gsub(country_names_suffix_re, '')

  locations = $geocoder_db.geocode(countryless_address)

  if locations and locations.length>0
    location = locations[0]
    if location[:number] and location[:street]
      street_address = location[:number]+' '+location[:street]
    else
      street_address = ''
    end
    info = {
      :latitude => location[:lat],
      :longitude => location[:lon],
      :country_code => 'US',
      :country_code3 => 'USA',
      :country_name => 'United States',
      :region => location[:state],
      :locality => location[:city],
      :street_address => street_address,
      :street_number => location[:number],
      :street_name => location[:street],
      :confidence => location[:score],
      :fips_county => location[:fips_county]
    }
  else
    info = nil
  end

  info
end

def canonicalize_street_string(street_string)

  output = street_string

  abbreviation_mappings = {
    'Street' => ['St'],
    'Drive' => ['Dr'],
    'Avenue' => ['Ave', 'Av'],
    'Court' => ['Ct'],
    'Road' => ['Rd'],
    'Lane' => ['Ln'],
    'Place' => ['Pl'],
    'Boulevard' => ['Blvd'],
    'Highway' => ['Hwy'],
    'Row' => ['Rw'],
  }

  abbreviation_mappings.each do |canonical, abbreviations|

    abbreviations_re = Regexp.new('^(.*[a-z]+.*)('+abbreviations.join('|')+')([^a-z]*)$', Regexp::IGNORECASE)
    output.gsub!(abbreviations_re, '\1'+canonical+'\3')

  end

  output
end

if __FILE__ == $0
  test_text = <<-TEXT
2543 Graystone Place, Simi Valley, CA 93065
11 Meadow Lane, Over, Cambridge CB24 5NF
400 Duboce Ave, San Francisco, CA 94117
TEXT

  test_text.each_line do |line|
    output = street2coordinates(line)
    puts line
    if output
      puts JSON.pretty_generate(output)
    end
    puts '************'
  end

end
