# lettrss.rb
# v0.1.0
# 2026-02-11
# (c) Pablo Enoc

require 'fileutils'
require 'date'

def prepend_front_matter(file_path, date, author_name)
  content = File.read(file_path)

  formatted_date = "#{date.strftime('%Y-%m-%d')} 17:00:00 -0800"

  front_matter = <<~YAML
  ---
  title: CHAPTER TITLE
  author: #{author_name}
  date: '#{formatted_date}'
  layout: post
  ---

  YAML

  File.write(file_path, front_matter + content)
end

def convert_xhtml_to_md(repo_name, start_date, author_name, section_delimeter)
  input_path  = "_epubs/#{repo_name}/src/epub/text"
  output_path = "_posts/#{repo_name}"

  FileUtils.mkdir_p(output_path)

  current_date = Date.parse(start_date)

  files = Dir.glob("#{input_path}/*.xhtml")

  # Convert files only if they have the word from the delimeter in them
  chapter_files = files.select { |f| File.basename(f).match?(/#{section_delimeter}-\d+/i) }

  # Sort by chapter number not alphabetically
  chapter_files.sort_by! do |file|
    File.basename(file)[/#{section_delimeter}-(\d+)/i, 1].to_i
  end

  chapter_files.each do |file|
    basename = File.basename(file, ".xhtml")
    dated_name = "#{current_date.strftime('%Y-%m-%d')}-#{basename}.md"
    md_file = File.join(output_path, dated_name)

    success = system(
      "pandoc",
      file,
      "-f", "html",
      "-t", "markdown",
      "--wrap=none",
      "-o", md_file
    )

    if success
      prepend_front_matter(md_file, current_date, author_name)
      puts "Converted #{dated_name}"
      current_date += 1
    else
      puts "Error converting #{file}"
    end
  end
end

welcome_message = <<TEXT


▗▖   ▗▄▄▄▖▗▄▄▄▖▗▄▄▄▖▗▄▄▖  ▗▄▄▖ ▗▄▄▖    
▐▌   ▐▌     █    █  ▐▌ ▐▌▐▌   ▐▌       
▐▌   ▐▛▀▀▘  █    █  ▐▛▀▚▖ ▝▀▚▖ ▝▀▚▖    
▐▙▄▄▖▐▙▄▄▖  █    █  ▐▌ ▐▌▗▄▄▞▘▗▄▄▞▘    

        (c) 2026 Pablo Enoc

               WELCOME

[1] Clone new book repository
[2] Repository Library
[3] Create posts from repository

TEXT

puts welcome_message
print '> '

selection = gets.chomp.strip.to_i

if selection === 1
  puts "\nRepository URL:\n"
  print '> '
  url = gets.chomp.strip
  
  Dir.chdir('_epubs') do
    system("git clone #{url}")
  end
end

if selection === 2
  puts "\nREPOSITORY LIBRARY\n\n"
  Dir.each_child('_epubs') do |repo_name|
    puts "\t#{repo_name}"
  end
  puts "\n"
end

if selection === 3
  puts "\nRepository name:\n"
  print '> '
  repo_name = gets.chomp.strip

  puts "\nSection delimiter (e.g. Chapter, Book, Unit):\n"
  print '> '
  section_delimeter = gets.chomp.strip

  puts "\nAuthor name:\n"
  print '> '
  author_name = gets.chomp.strip
  
  puts "\nSyndication start date (YYYY-MM-DD):\n"
  print '> '
  start_date = gets.chomp.strip

  puts "\n"
  puts "Directory _posts/#{repo_name} will be created with start date #{start_date}\n"
  puts "\nConfirm (y/n):\n"
  print '> '
  confirm = gets.chomp.strip

  if confirm === "y"
    puts "\nStarting conversion process...\n"
    convert_xhtml_to_md(repo_name, start_date, author_name, section_delimeter)
  end
  
end
