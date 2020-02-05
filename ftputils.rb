require 'net/ftp'
require 'colorize'

def ftp_files(prefix_to_remove, source_files, target_dir, hostname, username, password, exclude_files)
  Net::FTP.open(hostname, username, password) do |ftp|
    begin
      #   puts "Creating dir #{target_dir}"
      ftp.mkdir target_dir
    rescue StandardError
      puts $ERROR_INFO
    end
    progressbar = ProgressBar.create(total: source_files.size, progress_mark: '#', format: '%t: |%B|'.yellow)
    source_files.each do |source_file|
      target_file = source_file.pathmap(prefix_to_remove ? "%{^#{prefix_to_remove},#{target_dir}}p" : "#{target_dir}%s%p")

      next if exclude_files.include?(source_file)

      begin
        if File.directory?(source_file)
          progressbar.log "Creating dir #{target_file}"
          ftp.mkdir target_file
        else
          progressbar.log "Copying #{source_file} -> #{target_file}"
          ftp.putbinaryfile(source_file, target_file)
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
