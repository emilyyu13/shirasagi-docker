# This script creates a CSS directory node under the files node
puts "Starting CSS node creation..."

# Get the Kanamic site
site = Cms::Site.find_by(host: 'kanamic')
unless site
  puts "Error: Kanamic site not found"
  exit
end

puts "Found Kanamic site with ID: #{site.id}"

# Get the file node
file_node = Cms::Node.find_by(site_id: site.id, filename: 'files')
unless file_node
  puts "Error: File node not found"
  exit
end

puts "Found file node: #{file_node.name} (#{file_node.id})"

# Create CSS node under the file node
css_node = Cms::Node.find_or_create_by(site_id: site.id, filename: 'files/css') do |n|
  n.name = 'CSS'
  n.route = 'uploader/file'
  n.state = 'public'
  n.cur_node = file_node
end
puts "Created CSS node: #{css_node.name} (#{css_node.id})"

# Create CSS directory under the file node
css_dir = "#{site.path}/files/css"
Fs.mkdir_p(css_dir) unless Fs.exist?(css_dir)
puts "Created CSS directory: #{css_dir}"

# Upload CSS file to the CSS directory
css_content = File.read('/app/files/css/kanamic.css')
css_path = "#{css_dir}/kanamic.css"
Fs.binwrite(css_path, css_content)
puts "CSS file uploaded to #{css_path}"

# Create a file record in the database so it appears in the backend
file_model = SS::File.new
file_model.site_id = site.id
file_model.model = 'ss/file'
file_model.name = 'kanamic.css'
file_model.filename = 'css/kanamic.css'
file_model.content_type = 'text/css'
file_model.cur_user = Cms::User.find_by(email: 'sys@example.jp')
file_model.state = 'public'

# Read the file content
file_content = Fs.binread(css_path)
file_model.in_file = ActionDispatch::Http::UploadedFile.new(
  filename: 'kanamic.css',
  type: 'text/css',
  tempfile: Tempfile.new('kanamic.css').tap { |f| f.write(file_content); f.rewind }
)
file_model.save!
puts "File record created in database: #{file_model.name} (#{file_model.id})"

puts "CSS node creation completed successfully!"
