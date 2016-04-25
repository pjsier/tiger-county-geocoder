FROM ubuntu:14.04

MAINTAINER Patrick Sier <pjsier@gmail.com>

ARG FIPS

# Initial dependencies
RUN \
  apt-get update && \
  apt-get install -y wget build-essential sqlite3 libsqlite3-dev flex bison unzip git ruby-dev ruby1.9.1 && \
  gem install sqlite3 text bundler

# Get and build geocoder
RUN \
  git clone https://github.com/geocommons/geocoder.git && \
  cd geocoder && \
  make && \
  make install

# Get TIGER data from the census
RUN \
  mkdir /tiger && \
  cd /tiger && \
  wget ftp://ftp2.census.gov/geo/tiger/TIGER2015/EDGES/tl_2015_${FIPS}_edges.zip && \
  wget ftp://ftp2.census.gov/geo/tiger/TIGER2015/FEATNAMES/tl_2015_${FIPS}_featnames.zip && \
  wget ftp://ftp2.census.gov/geo/tiger/TIGER2015/ADDR/tl_2015_${FIPS}_addr.zip

# Build TIGER data within geocoder
RUN \
  cd geocoder && \
  mkdir data && \
  cd build && \
  ./tiger_import ../data/geocode.db /tiger

RUN \
  cd geocoder && \
  bin/rebuild_metaphones data/geocode.db && \
  chmod +x build/build_indexes && \
  build/build_indexes data/geocode.db && \
  chmod +x build/rebuild_cluster && \
  build/rebuild_cluster data/geocode.db

ENTRYPOINT ["ruby", "script/geocode_script.rb"]
