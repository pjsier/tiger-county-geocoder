# TIGER County Geocoder
## Batch geocode CSV files for a single US county

In order to run the geocoder for one US county, you'll need to find its associated
US Census FIPS code. FIPS codes can be found here: [Census FIPS Code Search](https://www.census.gov/geo/reference/codes/cou.html)

Uses `street2coordinates` functionality from [Pete Warden's Data Science Toolkit](https://github.com/petewarden/dstk).

Current example for Cook County, IL (FIPS 17031)

**To Build:** `docker build -t tiger-geo --build-arg FIPS=17031 .`

## Geocode CSV
For CSVs with a header row, run the container with first first argument being the
filename, and the second (optional) argument being the name of the column containing
address strings.

**Note:** The address column should contain the full address (not
split out into street, city, state).

To run from within the directory containing the CSV you want to geocode:

`docker run -v $(pwd):/script/data tiger-geo test_addr.csv address`

If no address column name is provided, the script will assume there is no header
and that the first column contains addresses. File will be outputted to the same
directory with the original filename and `_output` added.
