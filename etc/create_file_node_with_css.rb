# This script creates a file node with the exact name "ファイル" at the root level
# It ensures the CSS file appears when the "フォルダー" link is clicked

puts "Starting creation of file node with CSS..."

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

# Set site visibility and associate with group
site.group_ids = [group.id]
site.save!
puts "Updated site with group"

# Create CSS file content
css_content = <<~CSS
  /* Kanamic CSS Styles */
  body {
    font-family: 'Helvetica Neue', Arial, sans-serif;
    line-height: 1.6;
    color: #333;
    margin: 0;
    padding: 0;
  }

  .header-container {
    background-color: #0078d4;
    color: white;
    padding: 1rem 2rem;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .logo a {
    color: white;
    font-size: 1.5rem;
    font-weight: bold;
    text-decoration: none;
  }

  nav ul {
    display: flex;
    list-style: none;
    margin: 0;
    padding: 0;
  }

  nav li {
    margin-left: 1.5rem;
  }

  nav a {
    color: white;
    text-decoration: none;
  }

  nav a:hover {
    text-decoration: underline;
  }

  main {
    max-width: 1200px;
    margin: 0 auto;
    padding: 2rem;
  }

  .hero {
    text-align: center;
    padding: 3rem 1rem;
    background-color: #f5f5f5;
    margin-bottom: 2rem;
  }

  .hero h1 {
    font-size: 2.5rem;
    margin-bottom: 1rem;
    color: #0078d4;
  }

  .services {
    display: flex;
    flex-wrap: wrap;
    justify-content: space-between;
    gap: 2rem;
  }

  .service-item {
    flex: 1;
    min-width: 300px;
    padding: 1.5rem;
    border: 1px solid #ddd;
    border-radius: 5px;
  }

  .service-item h2 {
    color: #0078d4;
  }

  .service-item a {
    display: inline-block;
    margin-top: 1rem;
    padding: 0.5rem 1rem;
    background-color: #0078d4;
    color: white;
    text-decoration: none;
    border-radius: 3px;
  }

  .footer-container {
    background-color: #333;
    color: white;
    padding: 2rem;
    text-align: center;
  }

  .company-info h1,
  .service-detail h1,
  .contact h1 {
    color: #0078d4;
    border-bottom: 2px solid #0078d4;
    padding-bottom: 0.5rem;
    margin-bottom: 2rem;
  }

  .company-info section,
  .service-detail section,
  .contact section {
    margin-bottom: 2rem;
  }

  table {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 1rem;
  }

  th, td {
    padding: 0.75rem;
    border: 1px solid #ddd;
  }

  th {
    background-color: #f5f5f5;
    text-align: left;
    width: 30%;
  }

  .form-group {
    margin-bottom: 1.5rem;
  }

  label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: bold;
  }

  input, textarea {
    width: 100%;
    padding: 0.5rem;
    border: 1px solid #ddd;
    border-radius: 3px;
  }

  button {
    padding: 0.5rem 1rem;
    background-color: #0078d4;
    color: white;
    border: none;
    border-radius: 3px;
    cursor: pointer;
  }
CSS

# Remove existing nodes to avoid conflicts
existing_nodes = Cms::Node.where(site_id: site.id, filename: /^(css|file|ファイル)/)
existing_nodes.each do |node|
  puts "Removing existing node: #{node.name} (#{node.id})"
  node.destroy
end

# Create a file node at the root level with the exact name "ファイル"
file_node = Cms::Node.new
file_node.site_id = site.id
file_node.name = "ファイル"
file_node.filename = "ファイル"
file_node.route = "cms/node"
file_node.state = "public"
file_node.group_ids = [group.id]
file_node.save!
puts "Created file node: #{file_node.name} (#{file_node.id})"

# Create file directory under the site path
file_dir = "#{site.path}/ファイル"
Fs.mkdir_p(file_dir) unless Fs.exist?(file_dir)
puts "Created file directory: #{file_dir}"

# Upload CSS file to the file directory
css_path = "#{file_dir}/kanamic.css"
Fs.binwrite(css_path, css_content)
puts "CSS file uploaded to #{css_path}"

# Delete existing file records to avoid duplicates
existing_files = SS::File.where(site_id: site.id, filename: /^ファイル\//)
existing_files.each do |file|
  puts "Removing existing file: #{file.name} (#{file.id})"
  file.destroy
end

# Create a file record in the database so it appears in the backend
file = SS::File.new
file.model = "ss/file"
file.state = "public"
file.name = "kanamic.css"
file.filename = "ファイル/kanamic.css"
file.content_type = "text/css"
file.site_id = site.id
file.user_id = user.id

# Read the file content
file_content = Fs.binread(css_path)
tempfile = Tempfile.new(['kanamic', '.css'])
tempfile.write(file_content)
tempfile.rewind

file.in_file = ActionDispatch::Http::UploadedFile.new(
  filename: 'kanamic.css',
  type: 'text/css',
  tempfile: tempfile
)

file.save!
puts "Created file record in database: #{file.name} (#{file.id})"

puts "Creation of file node with CSS completed successfully!"
