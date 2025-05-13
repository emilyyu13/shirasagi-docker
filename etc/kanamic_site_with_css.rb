# This script creates a Kanamic-style company site and ensures the CSS file is visible in the backend
# It ensures the CSS file appears when the "フォルダー" link is clicked

puts "Starting Kanamic site creation with visible CSS file..."

# Get or create the Kanamic site
site = Cms::Site.find_or_create_by(host: 'kanamic') do |s|
  s.name = 'カナミック'
  s.domains = ['kanamic.localhost:3000']
end
puts "Site: #{site.name} (#{site.id})"

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

# Create file node for backend visibility
file_node = Cms::Node.find_or_create_by(site_id: site.id, filename: 'files') do |n|
  n.name = 'ファイル'
  n.route = 'uploader/file'
  n.state = 'public'
end
puts "Created file node: #{file_node.name} (#{file_node.id})"

# Create CSS folder node under the file node
css_node = Cms::Node.find_or_create_by(site_id: site.id, filename: 'files/css') do |n|
  n.name = 'CSS'
  n.route = 'uploader/file'
  n.state = 'public'
  n.cur_node = file_node
end
puts "Created CSS folder node: #{css_node.name} (#{css_node.id})"

# Create CSS directory under the file node
css_dir = "#{site.path}/files/css"
Fs.mkdir_p(css_dir) unless Fs.exist?(css_dir)
puts "Created CSS directory: #{css_dir}"

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

# Upload CSS file to the CSS directory
css_path = "#{css_dir}/kanamic.css"
Fs.binwrite(css_path, css_content)
puts "CSS file uploaded to #{css_path}"

# Delete existing file record if it exists to avoid duplicates
existing_file = SS::File.where(site_id: site.id, filename: 'files/css/kanamic.css').first
existing_file.destroy if existing_file
puts "Removed existing file record" if existing_file

# Create a file record in the database so it appears in the backend
file = SS::File.new
file.model = "ss/file"
file.state = "public"
file.name = "kanamic.css"
file.filename = "files/css/kanamic.css"
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

# Create a layout for the site
layout = Cms::Layout.find_or_create_by(site_id: site.id, filename: 'kanamic_layout') do |l|
  l.name = 'カナミックレイアウト'
  l.html = <<~HTML
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>カナミック</title>
      <link rel="stylesheet" href="/files/css/kanamic.css">
    </head>
    <body>
      <header class="header-container">
        <div class="logo">
          <a href="/">カナミック</a>
        </div>
        <nav>
          <ul>
            <li><a href="/company">会社情報</a></li>
            <li><a href="/services">サービス</a></li>
            <li><a href="/contact">お問い合わせ</a></li>
          </ul>
        </nav>
      </header>
      <main>
        {{ yield }}
      </main>
      <footer class="footer-container">
        <p>&copy; 2023 カナミック. All rights reserved.</p>
      </footer>
    </body>
    </html>
  HTML
end
puts "Created layout: #{layout.name} (#{layout.id})"

# Create the top page
top_page = Cms::Page.find_or_create_by(site_id: site.id, filename: 'index.html') do |p|
  p.name = 'トップページ'
  p.layout_id = layout.id
  p.html = <<~HTML
    <div class="hero">
      <h1>カナミックへようこそ</h1>
      <p>医療・介護・子育て支援のためのシステムを提供しています</p>
    </div>
    <div class="services">
      <div class="service-item">
        <h2>介護向けシステム</h2>
        <p>介護施設や在宅介護サービスのための効率的な管理システムを提供しています。</p>
        <a href="/services/care">詳細を見る</a>
      </div>
      <div class="service-item">
        <h2>医療向けシステム</h2>
        <p>医療機関向けの患者管理、予約管理、電子カルテシステムを提供しています。</p>
        <a href="/services/medical">詳細を見る</a>
      </div>
      <div class="service-item">
        <h2>子育て支援システム</h2>
        <p>保育施設や子育て支援センター向けの管理システムを提供しています。</p>
        <a href="/services/childcare">詳細を見る</a>
      </div>
    </div>
  HTML
end
puts "Created top page: #{top_page.name} (#{top_page.id})"

# Create company information page
company_page = Cms::Page.find_or_create_by(site_id: site.id, filename: 'company.html') do |p|
  p.name = '会社情報'
  p.layout_id = layout.id
  p.html = <<~HTML
    <div class="company-info">
      <h1>会社情報</h1>
      <section>
        <h2>会社概要</h2>
        <table>
          <tr>
            <th>会社名</th>
            <td>株式会社カナミック</td>
          </tr>
          <tr>
            <th>設立</th>
            <td>2006年4月</td>
          </tr>
          <tr>
            <th>資本金</th>
            <td>1億円</td>
          </tr>
          <tr>
            <th>代表者</th>
            <td>代表取締役社長 山本 康二</td>
          </tr>
          <tr>
            <th>従業員数</th>
            <td>約100名</td>
          </tr>
          <tr>
            <th>事業内容</th>
            <td>医療・介護・子育て支援向けシステムの開発・販売</td>
          </tr>
        </table>
      </section>
      <section>
        <h2>企業理念</h2>
        <p>カナミックは、「人と人をつなぐ」をモットーに、医療・介護・子育て支援の分野で、ITを活用した効率的なサービス提供を支援しています。私たちは、高齢化社会や少子化問題に直面する日本において、これらの分野の連携を強化し、より良いサービスを提供できる環境づくりに貢献します。</p>
      </section>
    </div>
  HTML
end
puts "Created company page: #{company_page.name} (#{company_page.id})"

# Create services page
services_page = Cms::Page.find_or_create_by(site_id: site.id, filename: 'services.html') do |p|
  p.name = 'サービス'
  p.layout_id = layout.id
  p.html = <<~HTML
    <div class="service-detail">
      <h1>サービス</h1>
      <section>
        <h2>介護向けシステム</h2>
        <p>介護施設や在宅介護サービスのための効率的な管理システムを提供しています。利用者情報の管理、ケアプランの作成、記録の管理、請求業務など、介護業務全般をサポートします。</p>
      </section>
      <section>
        <h2>医療向けシステム</h2>
        <p>医療機関向けの患者管理、予約管理、電子カルテシステムを提供しています。診療所から大規模病院まで、様々な規模の医療機関に対応したシステムを提供しています。</p>
      </section>
      <section>
        <h2>子育て支援システム</h2>
        <p>保育施設や子育て支援センター向けの管理システムを提供しています。園児情報の管理、日誌の記録、保護者との連絡など、保育業務全般をサポートします。</p>
      </section>
    </div>
  HTML
end
puts "Created services page: #{services_page.name} (#{services_page.id})"

# Create contact page
contact_page = Cms::Page.find_or_create_by(site_id: site.id, filename: 'contact.html') do |p|
  p.name = 'お問い合わせ'
  p.layout_id = layout.id
  p.html = <<~HTML
    <div class="contact">
      <h1>お問い合わせ</h1>
      <section>
        <h2>お問い合わせフォーム</h2>
        <form>
          <div class="form-group">
            <label for="name">お名前</label>
            <input type="text" id="name" name="name" required>
          </div>
          <div class="form-group">
            <label for="email">メールアドレス</label>
            <input type="email" id="email" name="email" required>
          </div>
          <div class="form-group">
            <label for="subject">件名</label>
            <input type="text" id="subject" name="subject" required>
          </div>
          <div class="form-group">
            <label for="message">メッセージ</label>
            <textarea id="message" name="message" rows="5" required></textarea>
          </div>
          <button type="submit">送信</button>
        </form>
      </section>
      <section>
        <h2>お問い合わせ先</h2>
        <p>株式会社カナミック</p>
        <p>〒100-0001 東京都千代田区1-1-1</p>
        <p>TEL: 03-1234-5678</p>
        <p>FAX: 03-1234-5679</p>
        <p>Email: info@kanamic.net</p>
      </section>
    </div>
  HTML
end
puts "Created contact page: #{contact_page.name} (#{contact_page.id})"

puts "Kanamic site creation with visible CSS file completed successfully!"
