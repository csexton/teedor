require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'


@growl_path = "/usr/local/bin/growlnotify"

def growl(title, msg, image)
  puts "grr: #{msg}"
  if File.exists? @growl_path
    raise "Growl Failed" unless system("#{@growl_path} -t '#{title}' -m '#{msg}' --image '#{image}'")
  end
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

source = "https://trac.backup.com/cc/projects.rss"
source = "https://trac.backup.com/minicc/projects.rss"
# url or local file
content = "" # raw content of rss feed will be loaded here
open(source) do |s| content = s.read end
rss = RSS::Parser.parse(content, false)

rss.items.each do |i|
  notify i
end


puts YAML.load_file("#{ENV["HOME"]}/.ccgrowl").inspect
