require 'rake'
require 'net/ftp'
require 'fileutils'
require 'io/console'
require 'colorize'
require 'ruby-progressbar'

def prompt(*args)
  print(*args)
  STDIN.gets.chomp
end

def ftp_files(prefixToRemove, sourceFileList, targetDir, hostname, username, password, exclude_files)
  Net::FTP.open(hostname, username, password) do |ftp|
    begin
    #   puts "Creating dir #{targetDir}"
      ftp.mkdir targetDir
    rescue StandardError
    #   puts $ERROR_INFO
    end
    progressbar = ProgressBar.create(:total => sourceFileList.size, :progress_mark => '#', :format => '%t: |%B|'.yellow)
    sourceFileList.each do |srcFile|
      targetFile = srcFile.pathmap(prefixToRemove ? "%{^#{prefixToRemove},#{targetDir}}p" : "#{targetDir}%s%p")

      next if exclude_files.include?(srcFile)

      begin
        if File.directory?(srcFile)
          progressbar.log "Creating dir #{targetFile}"
          ftp.mkdir targetFile
        else
          progressbar.log "Copying #{srcFile} -> #{targetFile}"
          ftp.putbinaryfile(srcFile, targetFile)
        end
        progressbar.increment 
      rescue StandardError
        progressbar.log $ERROR_INFO
      end
    end
    progressbar.finish
    progressbar.stop
  end
end

def cleanup
  puts 'Cleaning up generated site'
  FileUtils.remove_dir('_site', true)
end

def jekyll(directives = '')
  sh 'bundle exec jekyll ' + directives
end

task :default => :all

desc 'Clean up generated site'
task :clean do
  cleanup
end

desc 'Building Jekyll site'
task build: :clean do
  jekyll('build')
end

task :all => [:build, :ftp]

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
