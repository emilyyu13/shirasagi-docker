# This script fixes the CSS file visibility in the Shirasagi backend
# It ensures the CSS file appears when the "フォルダー" link is clicked

puts "Starting CSS file visibility fix..."

# Get the Kanamic site
site = Cms::Site.find_by(host: 'kanamic')
unless site
  puts "Error: Kanamic site not found"
  exit
end

puts "Found Kanamic site with ID: #{site.id}"

# Get or create a group if none exists
if Cms::Group.count == 0
  puts "No groups found, creating a default group"
  group = Cms::Group.create!(
    name: "管理グループ",
    order: 1
  )
  puts "Created group: #{group.name} (#{group.id})"
else
  group = Cms::Group.first
  puts "Using existing group: #{group.name} (#{group.id})"
end

# Set site visibility and associate with group
site.group_ids = [group.id]
site.save!
puts "Updated site with group"

# Get the admin user
user = Cms::User.find_by(email: 'sys@example.jp')
unless user
  puts "Error: Admin user not found"
  exit
end

# Ensure user has the group
user.group_ids = [group.id]
user.save!
puts "Updated user with group"

# Create file node for backend visibility
file_node = Cms::Node.find_or_create_by(site_id: site.id, filename: 'files') do |n|
  n.name = 'ファイル'
  n.route = 'uploader/file'
  n.state = 'public'
  n.group_ids = [group.id]
end
puts "Created file node: #{file_node.name} (#{file_node.id})"

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
file_model.filename = 'files/css/kanamic.css'
file_model.content_type = 'text/css'
file_model.cur_user = user
file_model.state = 'public'

# Read the file content
file_content = Fs.binread(css_path)
tempfile = Tempfile.new(['kanamic', '.css'])
tempfile.write(file_content)
tempfile.rewind

file_model.in_file = ActionDispatch::Http::UploadedFile.new(
  filename: 'kanamic.css',
  type: 'text/css',
  tempfile: tempfile
)
file_model.save!
puts "File record created in database: #{file_model.name} (#{file_model.id})"

puts "CSS file visibility fix completed successfully!"
