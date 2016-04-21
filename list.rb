#!/usr/bin/env ruby

require 'yaml'
require 'webhdfs'

config = YAML.load_file 'hdfs.yml'

client = WebHDFS::Client.new config['host'], config['port'], config['username']

path = ARGV[0]
path = '/' unless path

results = client.list path

results.each do |item|
  case item['type']
  when 'DIRECTORY'
    puts "#{item['pathSuffix']}/"
  when 'FILE'
    puts "#{item['pathSuffix']}"
  else
    puts items.inspect
  end
end
