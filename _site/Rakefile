# Rakefile
require "date"
require 'fileutils'
require "yaml"

POSTS_DIR = "_posts"
POST_FILES = Dir.glob("#{POSTS_DIR}/**/*.md").sort_by { |f| File.mtime(f) }.reverse

task default: :serve

desc "Serve site locally" 
task :serve do 
  sh "bundle exec jekyll serve --host 0.0.0.0"
end

desc "Build the site with JEKYLL_ENV=production"
task :build do
  sh "JEKYLL_ENV=production bundle exec jekyll build"
end


namespace :posts do
  
  def confirm_posts_not_empty
    if POST_FILES.empty?
      puts "📭 No posts found in #{POSTS_DIR}"
      exit
    end
  end
  
  def get_post_status(file)
    content = File.read(file)

    if content =~ /\A---\s*\n(.*?)\n---\s*\n/m
      front_matter = YAML.safe_load($1, permitted_classes: [Time])
      status_text = front_matter["published"] == false ? "unpublished" : "published"
      padded = status_text.ljust(11)

      return status_text == "published" ?
        "\e[0;32m#{padded}\e[0m" :
        "\e[0;33m#{padded}\e[0m"
    else
      "unknown".ljust(11)
    end
  end
  
  
  desc "List all blog posts"
  task :all do 
    
    confirm_posts_not_empty
  
    puts "\nAll Posts:\n\n"
  
    POST_FILES.each_with_index do |file, index|
      post_status = get_post_status(file) # published, unpublished
      puts "%02d | %s | %s" % [index + 1, post_status, file]
    end
  end
  
  desc "List recent blog posts"
  task :recent do
    
    confirm_posts_not_empty
  
    puts "\nRecent Posts:\n\n"
  
    POST_FILES.first(5).each_with_index do |file, index|
      post_status = get_post_status(file) # published, unpublished
      puts "%02d | %s | %s" % [index + 1, post_status, file]
    end
  end
  
  desc "Create a new post with front matter"
  task :new do
    print "Post Title: "
    title = STDIN.gets.chomp.strip
  
    if title.empty?
      puts "❌ Empty title! Aborting..."
      exit
    end
  
    slug = title.downcase.gsub(' ', '-').gsub(/[^\w-]/, '')
    date = Date.today
    time = Time.now.getlocal("-07:00")
    months = %w[enero febrero marzo abril mayo junio julio agosto septiembre octubre noviembre diciembre]
    filename = "#{date}-#{slug}.md"
  
    # date 2025-04-22 yields dir_path of _posts/2025/abril
    dir_path = File.join(POSTS_DIR, date.year.to_s, months[date.month - 1]) 
  
    # e.g. _posts/2025/abril/some-title.md
    path = File.join(dir_path, filename)
  
    FileUtils.mkdir_p(dir_path)
  
    if File.exist?(path)
      puts "❌ A file with this name exists already. Aborting..."
      exit
    end
  
    front_matter = {
      "layout" => "post",
      "title" => title,
      "date" => time.strftime("%Y-%m-%d %H:%M:%S %z"),
      "categories" => [],
      "tags" => []
    }

    File.open(path, "w") do |file|
      file.puts front_matter.to_yaml
      file.puts "---\n"
    end
  
    puts "✅ File saved in #{path}"
  end
end