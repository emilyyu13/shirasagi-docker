# This script creates a complete Kanamic site with CSS file visible in the backend folder view
# It ensures the CSS file appears when the "フォルダー" link is clicked at http://localhost:3000/.s2/cms/contents

puts "Starting creation of complete Kanamic site with visible CSS file..."

# Get the Kanamic site
site = Cms::Site.find_by(host: 'kanamic')
unless site
  puts "Creating Kanamic site..."
  site = Cms::Site.create!(
    name: "カナミック",
    host: "kanamic",
    domains: "kanamic.localhost:3000",
    state: "public"
  )
  puts "Created Kanamic site with ID: #{site.id}"
else
  puts "Found existing Kanamic site with ID: #{site.id}"
end

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

# Create a layout for the site
puts "Creating layout..."
layout = Cms::Layout.find_or_create_by(
  site_id: site.id,
  name: "カナミックレイアウト",
  filename: "kanamic_layout"
)
layout.html = <<~HTML
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>カナミック</title>
    <link rel="stylesheet" href="/css/kanamic.css">
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
layout.save!
puts "Layout created: #{layout.name}"

# Create a home page
puts "Creating home page..."
top_page = Cms::Page.find_or_create_by(
  site_id: site.id,
  name: "トップページ",
  filename: "index.html"
)
top_page.layout_id = layout.id
top_page.html = <<~HTML
  <div class="hero">
    <h1>カナミックへようこそ</h1>
    <p>医療・介護・子育て支援のためのシステムを提供しています</p>
  </div>
  <div class="services">
    <div class="service-item">
      <h2>介護向けシステム</h2>
      <p>介護施設や在宅介護サービスのための効率的な管理システムを提供しています。</p>
      <a href="/services#care">詳細を見る</a>
    </div>
    <div class="service-item">
      <h2>医療向けシステム</h2>
      <p>医療機関向けの患者管理、予約管理、電子カルテシステムを提供しています。</p>
      <a href="/services#medical">詳細を見る</a>
    </div>
    <div class="service-item">
      <h2>子育て支援システム</h2>
      <p>保育園、幼稚園、学童保育などの子育て支援施設向けの管理システムを提供しています。</p>
      <a href="/services#childcare">詳細を見る</a>
    </div>
  </div>
HTML
top_page.save!
puts "Home page created: #{top_page.name}"

# Create company information page
puts "Creating company page..."
company_page = Cms::Page.find_or_create_by(
  site_id: site.id,
  name: "会社情報",
  filename: "company.html"
)
company_page.layout_id = layout.id
company_page.html = <<~HTML
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
      <p>私たちカナミックは、「人々の健康と幸福に貢献する」という理念のもと、医療・介護・子育て支援の分野でITを活用したソリューションを提供しています。</p>
      <p>高齢化社会や少子化問題など、現代社会が直面する課題に対して、テクノロジーの力で解決策を提案し、より良い社会の実現を目指しています。</p>
    </section>
  </div>
HTML
company_page.save!
puts "Company page created: #{company_page.name}"

# Create services page
puts "Creating services page..."
services_page = Cms::Page.find_or_create_by(
  site_id: site.id,
  name: "サービス",
  filename: "services.html"
)
services_page.layout_id = layout.id
services_page.html = <<~HTML
  <div class="service-detail">
    <h1>サービス</h1>
    <section id="care">
      <h2>介護向けシステム</h2>
      <p>介護施設や在宅介護サービスのための効率的な管理システムを提供しています。利用者情報の管理、ケアプランの作成、記録の管理、請求業務など、介護業務全般をサポートします。</p>
      <ul>
        <li>利用者情報管理</li>
        <li>ケアプラン作成支援</li>
        <li>記録管理システム</li>
        <li>請求業務効率化</li>
        <li>スタッフシフト管理</li>
      </ul>
    </section>
    <section id="medical">
      <h2>医療向けシステム</h2>
      <p>医療機関向けの患者管理、予約管理、電子カルテシステムを提供しています。診療所から大規模病院まで、規模に合わせたカスタマイズが可能です。</p>
      <ul>
        <li>患者情報管理</li>
        <li>予約管理システム</li>
        <li>電子カルテ</li>
        <li>診療報酬請求</li>
        <li>医療データ分析</li>
      </ul>
    </section>
    <section id="childcare">
      <h2>子育て支援システム</h2>
      <p>保育園、幼稚園、学童保育などの子育て支援施設向けの管理システムを提供しています。園児情報の管理、登降園管理、保護者とのコミュニケーションツールなど、子育て支援業務をトータルにサポートします。</p>
      <ul>
        <li>園児情報管理</li>
        <li>登降園管理</li>
        <li>保護者連絡アプリ</li>
        <li>献立・アレルギー管理</li>
        <li>成長記録管理</li>
      </ul>
    </section>
  </div>
HTML
services_page.save!
puts "Services page created: #{services_page.name}"

# Create contact page
puts "Creating contact page..."
contact_page = Cms::Page.find_or_create_by(
  site_id: site.id,
  name: "お問い合わせ",
  filename: "contact.html"
)
contact_page.layout_id = layout.id
contact_page.html = <<~HTML
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
          <label for="company">会社名</label>
          <input type="text" id="company" name="company">
        </div>
        <div class="form-group">
          <label for="phone">電話番号</label>
          <input type="tel" id="phone" name="phone">
        </div>
        <div class="form-group">
          <label for="subject">お問い合わせ件名</label>
          <input type="text" id="subject" name="subject" required>
        </div>
        <div class="form-group">
          <label for="message">お問い合わせ内容</label>
          <textarea id="message" name="message" rows="5" required></textarea>
        </div>
        <button type="submit">送信する</button>
      </form>
    </section>
    <section>
      <h2>お問い合わせ先</h2>
      <table>
        <tr>
          <th>住所</th>
          <td>〒100-0001 東京都千代田区千代田1-1-1 カナミックビル</td>
        </tr>
        <tr>
          <th>電話番号</th>
          <td>03-1234-5678</td>
        </tr>
        <tr>
          <th>FAX</th>
          <td>03-1234-5679</td>
        </tr>
        <tr>
          <th>メール</th>
          <td>info@kanamic.net</td>
        </tr>
        <tr>
          <th>営業時間</th>
          <td>平日 9:00〜18:00（土日祝休）</td>
        </tr>
      </table>
    </section>
  </div>
HTML
contact_page.save!
puts "Contact page created: #{contact_page.name}"

# Remove existing nodes to avoid conflicts
existing_nodes = Cms::Node.where(site_id: site.id, filename: /^(css|file|files)/)
existing_nodes.each do |node|
  puts "Removing existing node: #{node.name} (#{node.id})"
  node.destroy
end

# Create a folder node for CSS
puts "Creating CSS folder node..."
css_node = Cms::Node.new
css_node.site_id = site.id
css_node.name = "CSS"
css_node.filename = "css"
css_node.route = "cms/node"
css_node.state = "public"
css_node.group_ids = [group.id]
css_node.save!
puts "Created CSS folder node: #{css_node.name} (#{css_node.id})"

# Create CSS directory under the site path
css_dir = "#{site.path}/css"
Fs.mkdir_p(css_dir) unless Fs.exist?(css_dir)
puts "Created CSS directory: #{css_dir}"

# Upload CSS file to the CSS directory
css_path = "#{css_dir}/kanamic.css"
Fs.binwrite(css_path, css_content)
puts "CSS file uploaded to #{css_path}"

# Delete existing file records to avoid duplicates
existing_files = SS::File.where(site_id: site.id, filename: /^css\//)
existing_files.each do |file|
  puts "Removing existing file: #{file.name} (#{file.id})"
  file.destroy
end

# Create a file record in the database so it appears in the backend
file = SS::File.new
file.model = "ss/file"
file.state = "public"
file.name = "kanamic.css"
file.filename = "css/kanamic.css"
file.content_type = "text/css"
file.site_id = site.id
file.user_id = user.id
file.group_ids = [group.id]

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

# Create a direct association between the CSS node and the file
css_node.file_ids = [file.id]
css_node.save!
puts "Associated CSS file with CSS node"

puts "Creation of complete Kanamic site with visible CSS file completed successfully!"
puts "You can now access the site at http://kanamic.localhost:3000"
puts "To view the CSS file in the backend, go to http://localhost:3000/.s2/cms/contents and click on 'フォルダー'"
