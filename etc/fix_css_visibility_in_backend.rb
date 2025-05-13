# This script fixes the CSS file visibility in the Shirasagi backend
# It ensures the CSS file appears when the "フォルダー" link is clicked

puts "Starting CSS backend visibility fix..."

# Get the Kanamic site
site = Cms::Site.find_by(host: 'kanamic')
unless site
  puts "Error: Kanamic site not found"
  exit
end

puts "Found Kanamic site with ID: #{site.id}"

# Create a proper uploader node that will be visible in the backend
uploader_node = Cms::Node.find_or_create_by(site_id: site.id, filename: 'files') do |n|
  n.name = 'ファイル'
  n.route = 'uploader/file'
  n.state = 'public'
end
puts "Created uploader node: #{uploader_node.name} (#{uploader_node.id})"

# Create css directory under the uploader node
css_dir = "#{site.path}/files/css"
Fs.mkdir_p(css_dir) unless Fs.exist?(css_dir)
puts "Created CSS directory: #{css_dir}"

# Upload CSS file to the uploader directory
css_content = File.read('/app/files/css/kanamic.css')
css_path = "#{css_dir}/kanamic.css"
Fs.binwrite(css_path, css_content)
puts "CSS file uploaded to #{css_path}"

# Create a file record in the database so it appears in the backend
file_model = SS::File.new
file_model.site_id = site.id
file_model.model = 'ss/file'
file_model.name = 'kanamic.css'
file_model.filename = 'kanamic.css'
file_model.content_type = 'text/css'
# Read the file content
file_content = Fs.binread(css_path)
file_model.in_file = ActionDispatch::Http::UploadedFile.new(
  filename: 'kanamic.css',
  type: 'text/css',
  tempfile: Tempfile.new('kanamic.css').tap { |f| f.write(file_content); f.rewind }
)
file_model.save!
puts "File record created in database: #{file_model.name} (#{file_model.id})"

# Update the layout to reference the new CSS file location
layout = Cms::Layout.find_by(site_id: site.id, filename: 'kanamic_layout')
if layout
  new_html = layout.html.gsub('/uploader/css/kanamic.css', '/files/css/kanamic.css')
  layout.html = new_html
  layout.save!
  puts "Layout updated to reference new CSS file location"
else
  puts "Warning: Layout not found"
end

puts "CSS backend visibility fix completed successfully!"
