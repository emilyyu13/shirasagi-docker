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

# Create CSS file content if it doesn't exist in the app directory
css_file_path = '/app/files/css/kanamic.css'
unless Fs.exist?(css_file_path)
  Fs.mkdir_p('/app/files/css') unless Fs.exist?('/app/files/css')
  Fs.write(css_file_path, <<~CSS)
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
  puts "Created CSS file at #{css_file_path}"
end

# Upload CSS file to the CSS directory
css_content = Fs.read(css_file_path)
css_path = "#{css_dir}/kanamic.css"
Fs.binwrite(css_path, css_content)
puts "CSS file uploaded to #{css_path}"

# Delete existing file record if it exists to avoid duplicates
existing_file = SS::File.where(site_id: site.id, filename: 'files/css/kanamic.css').first
existing_file.destroy if existing_file
puts "Removed existing file record" if existing_file

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

# Update the layout to reference the new CSS file location if it exists
begin
  layout = Cms::Layout.where(site_id: site.id, filename: 'kanamic_layout').first
  if layout
    # Only update if the layout contains a reference to the CSS file that needs updating
    if layout.html.include?('/uploader/css/kanamic.css')
      new_html = layout.html.gsub('/uploader/css/kanamic.css', '/files/css/kanamic.css')
      layout.html = new_html
      layout.save!
      puts "Layout updated to reference new CSS file location"
    else
      puts "Layout already has correct CSS reference"
    end
  else
    puts "Layout not found, but it will be created by the initialization script"
  end
rescue => e
  puts "Error handling layout: #{e.message}"
  puts "This is expected if the layout doesn't exist yet"
end

puts "CSS file visibility fix completed successfully!"
