require 'json'
require 'csv'
require '/script/street2coordinates'

def geocode_csv(csv_contents, addr_idx, headers)
  # Create empty csv to return, add first row from input
  geocoded_csv = []

  # Check if headers exist, if so, pull first row and add lat and lon
  if headers
    to_geocode = csv_contents.drop(1)
    geocoded_csv[0] = csv_contents[0]
    geocoded_csv[0].push("lat", "lon")
  else
    to_geocode = csv_contents
  end

  # Iterate through ignoring the header row
  to_geocode.each do |i|
    # Geocode, and push the results to a new row, added to the new csv
    geocoded = street2coordinates([i[addr_idx]])
    lat = geocoded[i[addr_idx]][:latitude]
    lon = geocoded[i[addr_idx]][:longitude]
    geo_row = i
    geo_row.push(lat, lon)
    geocoded_csv.push(geo_row)
  end

  return geocoded_csv
end

def write_output(csv_name, geocoded_csv)
  # Adjust filename to include output
  output_filename = csv_name.insert(-5, "_output")

  # Write to CSV
  CSV.open(output_filename, "w") do |csv|
    geocoded_csv.each do |row|
      csv << row
    end
  end
end

if ARGV.length == 0
  puts "No arguments supplied. Exiting..."
else
  csv_name = "script/" + ARGV[0]
  csv_contents = CSV.read(csv_name)

  # Check if more than one argument, if so, second argument becomes address column
  if ARGV.length > 1
    addr_col = ARGV[1]
  else
    # If no second argument provided, assume no headers and first column
    geocoded_csv = geocode_csv(csv_contents, 0, false)
    write_output(csv_name, geocoded_csv)
  end

  # If address column name supplied, find index
  csv_contents[0].each_with_index do |item, index|
    if item == addr_col
      adx = index
      # Get address index and geocode
      geocoded_csv = geocode_csv(csv_contents, adx, true)
      write_output(csv_name, geocoded_csv)
      break
    end
  end
end
