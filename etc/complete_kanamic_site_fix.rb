# This script combines all fixes for the Kanamic site
# 1. Creates the site if it doesn't exist
# 2. Fixes user permissions
# 3. Creates CSS file and ensures it's visible in the backend

puts "Starting complete Kanamic site fix..."

# Get or create the Kanamic site
site = Cms::Site.find_or_create_by(host: 'kanamic') do |s|
  s.name = "カナミック"
  s.domains = "kanamic.localhost:3000"
end

puts "Found/created Kanamic site with ID: #{site.id}"

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

# Create nodes
top_node = Cms::Node.find_or_create_by(site_id: site.id, filename: 'index') do |n|
  n.name = 'トップページ'
  n.route = 'cms/node'
  n.state = 'public'
end

company_node = Cms::Node.find_or_create_by(site_id: site.id, filename: 'company') do |n|
  n.name = '企業情報'
  n.route = 'cms/node'
  n.state = 'public'
end

nursing_node = Cms::Node.find_or_create_by(site_id: site.id, filename: 'nursing') do |n|
  n.name = '介護向けシステム'
  n.route = 'cms/node'
  n.state = 'public'
end

medical_node = Cms::Node.find_or_create_by(site_id: site.id, filename: 'medical') do |n|
  n.name = '医療向けシステム'
  n.route = 'cms/node'
  n.state = 'public'
end

childcare_node = Cms::Node.find_or_create_by(site_id: site.id, filename: 'childcare') do |n|
  n.name = '子育て支援システム'
  n.route = 'cms/node'
  n.state = 'public'
end

contact_node = Cms::Node.find_or_create_by(site_id: site.id, filename: 'contact') do |n|
  n.name = 'お問合せ'
  n.route = 'cms/node'
  n.state = 'public'
end

# Create file node for backend visibility
file_node = Cms::Node.find_or_create_by(site_id: site.id, filename: 'files') do |n|
  n.name = 'ファイル'
  n.route = 'uploader/file'
  n.state = 'public'
end
puts "Created file node: #{file_node.name} (#{file_node.id})"

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
file_model.cur_user = user
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

# Create layout
layout = Cms::Layout.find_or_create_by(site_id: site.id, filename: 'kanamic_layout') do |l|
  l.name = 'カナミックレイアウト'
  l.html = '
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>{{ page.name }} - カナミック</title>
      <link rel="stylesheet" href="/files/css/kanamic.css">
    </head>
    <body>
      <header>
        <div class="header-container">
          <div class="logo">
            <a href="/">カナミック</a>
          </div>
          <nav>
            <ul>
              <li><a href="/nursing/">介護向けシステム</a></li>
              <li><a href="/medical/">医療向けシステム</a></li>
              <li><a href="/childcare/">子育て支援システム</a></li>
              <li><a href="/company/">企業情報</a></li>
              <li><a href="/contact/">お問合せ</a></li>
            </ul>
          </nav>
        </div>
      </header>
      
      <main>
        {{ yield }}
      </main>
      
      <footer>
        <div class="footer-container">
          <div class="footer-info">
            <p>株式会社カナミックネットワーク</p>
            <p>〒150-0013 東京都渋谷区恵比寿1-19-19 恵比寿ビジネスタワー</p>
          </div>
        </div>
      </footer>
    </body>
    </html>
  '
end
puts "Created layout: #{layout.name} (#{layout.id})"

puts "Complete Kanamic site fix completed successfully!"
