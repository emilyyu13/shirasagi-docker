# Initialize Kanamic site
puts "Creating Kanamic site..."

# Find or create site
site = Cms::Site.find_or_create_by(host: "kanamic") do |s|
  s.name = "カナミック"
  s.domains = "kanamic.localhost:3000"
end

puts "Created site with ID: #{site.id}"

# Set site visibility
site.group_ids = Cms::Group.all.pluck(:id)  # Associate with all groups
site.save!
puts "Site visibility settings updated"

# Create basic nodes
puts "Creating basic nodes..."

top_node = Cms::Node.find_or_create_by(site_id: site.id, filename: 'index') do |n|
  n.name = 'トップページ'
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

puts "Kanamic site initialized successfully!"
