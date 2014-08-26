MAIN_DIR=File.expand_path(File.dirname(__FILE__))
ENV["MAIN_DIR"]=MAIN_DIR
# ENV["RACK_ENV"]="production"

# add our root and lib dirs to the load path
$:.unshift MAIN_DIR
$:.unshift "#{MAIN_DIR}/lib/"
$:.unshift "#{MAIN_DIR}/lib/models/"
$:.unshift "#{MAIN_DIR}/lib/helpers/"

require "app"

run MMRToStravaApplication
