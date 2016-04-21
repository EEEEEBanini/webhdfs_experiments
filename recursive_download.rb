#!/usr/bin/env ruby

require 'yaml'
require 'webhdfs'

BUFFER_SIZE = 1024 * 1024

def download_file(client, base_path, file_name, file_length)
  f = File.new(file_name, 'w+b')
  file_path = "#{base_path}#{file_name}"
  if (file_length < BUFFER_SIZE)
    f.write(client.read(file_path))
  else
    offset = 0
    while offset < file_length do
      f.write(client.read(file_path, offset: offset, length: BUFFER_SIZE))
      offset += BUFFER_SIZE
      print '.'
    end
    puts ""
  end
  f.close
end

def download_directory(client, base_path)
  results = client.list base_path

  results.each do |item|
    item_type = item['type']
    item_path = item['pathSuffix']
    item_length = item['length']

    case item_type
    when 'DIRECTORY'
      puts "Creating directory #{Dir.pwd}/#{item_path}/"
      Dir.mkdir item_path
      Dir.chdir item_path
      download_directory client, "#{base_path}#{item_path}/"
      Dir.chdir '..'
    when 'FILE'
      puts "Downloading file #{Dir.pwd}/#{item_path}"
      download_file client, base_path, item_path, item_length
    else
      puts "Warning: unknown type encountered - #{item_path} - #{item_type}"
    end
  end
end

config = YAML.load_file 'hdfs.yml'

client = WebHDFS::Client.new config['host'], config['port'], config['username']

start_path = ARGV[0]
start_path = '/' unless start_path
start_path = "#{start_path}/" unless start_path.end_with?('/')

Dir.mkdir 'output'
Dir.chdir 'output'

download_directory client, start_path

Dir.chdir '..'
