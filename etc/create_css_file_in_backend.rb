# This script creates a CSS file that is visible in the Shirasagi backend
# It ensures the CSS file appears when the "フォルダー" link is clicked

puts "Starting CSS file creation in backend..."

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

# Create the file directly in the database
file = SS::File.new
file.model = "ss/file"
file.state = "public"
file.name = "kanamic.css"
file.filename = "kanamic.css"
file.content_type = "text/css"
file.site_id = site.id
file.user_id = user.id
# SS::File doesn't have group_ids attribute
# file.group_ids = [group.id]

# Read the file content
file_content = Fs.binread(css_file_path)
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

puts "CSS file creation in backend completed successfully!"
