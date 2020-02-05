require 'rake'
require 'net/ftp'
require 'fileutils'
require 'io/console'
require 'colorize'
require 'yaml'
require 'ruby-progressbar'

require_relative './ftputils'

def prompt(*args)
  print(*args)
  STDIN.gets.chomp
end

def jekyll(directives = '')
  sh 'bundle exec jekyll ' + directives
end

def create_post(title, author, image_url)
  current_date = Time.now

  file_name = "_posts/#{current_date.strftime('%Y-%m-%d')}-#{title.sub(/\s/, '-')}.md"
  File.open(file_name, 'w') do |f|
    f.puts '---'
    f.puts 'layout: post'
    f.puts "title: \"#{title}\""
    f.puts "author: #{author}"
    f.puts "imageurl: \"#{image_url}\""
    f.puts '---'
    f.puts
    f.puts '<!-- Excerpt content -->'
    f.puts
    f.puts '<!-- more -->'
    f.puts
    f.puts '<!-- Content -->'
  end
end

desc 'Build and upload the website'
task default: %i[build ftp]

desc 'Create a new blog post'
task :post do
  data = YAML.load_file '_config.yml'
  default_author = data['defaults'][0]['values']['author']
  default_image = data['defaults'][0]['values']['imageurl']

  title = prompt 'Post title: '

  author = prompt "Post author (default: #{default_author}): "
  author = default_author if author.empty?

  image = prompt "Post image name (default: #{default_image}): "
  image = image.empty? ? default_image : "assets/images/#{image}"

  create_post title, author, image
end

desc 'Clean up generated site'
task :clean do
  puts 'Cleaning up generated site'
  FileUtils.remove_dir('_site', true)
end

desc 'Build Jekyll site'
task build: :clean do
  jekyll('build')
end

desc 'Upload the file via FTP'
task :ftp do
  begin
    username = prompt 'Username: '
    password = IO.console.getpass 'Password: '
    ftp_files('_site/', FileList['_site/**/*'], '/', 'ftp.onstatic-it.setupdns.net', username, password, FileList['**/*.ini'])
  rescue Net::FTPPermError
    puts 'Wrong credentials'.red
    retry
  end
end
