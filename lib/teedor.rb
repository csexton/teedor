require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'


class Teedor

  def initialize()
    @growl_path = "/usr/local/bin/growlnotify"
    @config_file = "#{ENV['HOME']}/.teedor.yml"
    read_config

  end

  def growl(title, msg, image)
    puts "grr: #{msg}"
    if File.exists? @growl_path
      raise "Growl Failed" unless system("#{@growl_path} -t '#{title}' -m '#{msg}' --image '#{image}'")
    end
  end

  def write(filename, hash)
    puts "writing to #{filename}"
    File.open(filename, "w") do |f|
      f.write(hash.to_yaml)
    end
  end

  def read_config
    if(File.exists? @config_file)
      @config = YAML.load_file(@config_file)
      puts "loaded config file"
    else
      @config = {}
      puts "no config file"
    end

  end

  def save_config
    write(@config_file, @config)
  end


  def notify(item)
    image = "#{File.dirname(File.expand_path(__FILE__))}/../resources/red_x.png"
    if (item.title =~ /(success$)/)
      image = "#{File.dirname(File.expand_path(__FILE__))}/../resources/green_check.png"
    end

    item.description.gsub(/<\/?[^>]*>/, "") =~ /(^Revision.*$)/
      description = $1
    growl item.title, description, image
    puts item.inspect
  end

  def get_url(url)

    # url or local file
    content = "" # raw content of rss feed will be loaded here
    open(url) do |s| content = s.read end
    rss = RSS::Parser.parse(content, false)

    rss.items.each do |i|
      notify i
      puts i.link
      puts key = i.link.gsub(/\/\w+$/, "") # delete the build ID from this one
      puts val = i.link.match(/(\w+$)/).to_s # store the build number to track
      @config[key] = val
      save_config
    end
  end


end
