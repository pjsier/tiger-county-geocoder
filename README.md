# TIGER County Geocoder
## Geocoder for batch geocoding of addresses in one US County

In order to run the geocoder for one US county, you'll need to find its associated
US Census FIPS code. FIPS codes can be found here: [Census FIPS Code Search](https://www.census.gov/geo/reference/codes/cou.html)

Uses `street2coordinates` functionality from Pete Warden's Data Science Toolkit.

Current example for Cook County, IL (FIPS 17031)

**To Build:** `docker build -t tiger-geo --build-arg FIPS=17031 .`

**To Run:** `docker run -v /Users/example/tiger-county-geocoder:/script tiger-geo script/geocode_script.rb`
