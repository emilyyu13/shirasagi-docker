
docker-compose run app rake ss:create_site data='{ name: "カナミック", host: "kanamic", domains: "kanamic.localhost:3000" }'

docker-compose run app bundle exec rails r "
  site = Cms::Site.find_by(host: 'kanamic')
  site.group_ids = Cms::Group.all.pluck(:id)  # Associate with all groups
  site.permission_level = 1                   # Set permission level
  site.save!
  puts 'Site visibility settings updated'
"

docker-compose run app bundle exec rails r "
  site = Cms::Site.find_by(host: 'kanamic')
  
  top_node = Cms::Node.create!(
    site_id: site.id,
    name: 'トップページ',
    filename: 'index',
    route: 'cms/node',
    state: 'public'
  )
  
  company_node = Cms::Node.create!(
    site_id: site.id,
    name: '企業情報',
    filename: 'company',
    route: 'cms/node',
    state: 'public'
  )
  
  nursing_node = Cms::Node.create!(
    site_id: site.id,
    name: '介護向けシステム',
    filename: 'nursing',
    route: 'cms/node',
    state: 'public'
  )
  
  medical_node = Cms::Node.create!(
    site_id: site.id,
    name: '医療向けシステム',
    filename: 'medical',
    route: 'cms/node',
    state: 'public'
  )
  
  childcare_node = Cms::Node.create!(
    site_id: site.id,
    name: '子育て支援システム',
    filename: 'childcare',
    route: 'cms/node',
    state: 'public'
  )
  
  contact_node = Cms::Node.create!(
    site_id: site.id,
    name: 'お問合せ',
    filename: 'contact',
    route: 'cms/node',
    state: 'public'
  )
  
  top_page = Cms::Page.create!(
    site_id: site.id,
    name: 'トップページ',
    filename: 'index',
    route: 'cms/page',
    state: 'public',
    html: '
      <div class=\"main-visual\">
        <div class=\"main-content\">
          <h1>人生を抱きしめるクラウド</h1>
          <p>子育てにはじまり、介護まで。<br>人の幸せを支える、クラウド技術があります。</p>
        </div>
      </div>
      
      <div class=\"service-section\">
        <h2>サービス紹介</h2>
        <div class=\"service-items\">
          <div class=\"service-item\">
            <h3>介護向けシステム</h3>
            <p>介護業務を効率化し、質の高いケアを実現するクラウドシステム</p>
            <a href=\"/nursing/\">詳細はこちら</a>
          </div>
          <div class=\"service-item\">
            <h3>医療向けシステム</h3>
            <p>医療機関の業務をサポートし、患者ケアを向上させるシステム</p>
            <a href=\"/medical/\">詳細はこちら</a>
          </div>
          <div class=\"service-item\">
            <h3>子育て支援システム</h3>
            <p>子育て支援施設の運営をサポートするクラウドシステム</p>
            <a href=\"/childcare/\">詳細はこちら</a>
          </div>
        </div>
      </div>
      
      <div class=\"company-section\">
        <h2>企業情報</h2>
        <p>カナミックは、介護・医療・子育て支援のクラウドサービスを提供する企業です。</p>
        <a href=\"/company/\">企業情報を見る</a>
      </div>
      
      <div class=\"contact-section\">
        <h2>お問合せ</h2>
        <p>サービスに関するお問合せはこちらから</p>
        <a href=\"/contact/\">お問合せフォーム</a>
      </div>
    '
  )
  
  company_page = Cms::Page.create!(
    site_id: site.id,
    name: '企業情報',
    filename: 'company/index',
    route: 'cms/page',
    state: 'public',
    html: '
      <div class=\"company-info\">
        <h1>企業情報</h1>
        
        <section class=\"company-profile\">
          <h2>会社概要</h2>
          <table>
            <tr>
              <th>会社名</th>
              <td>株式会社カナミックネットワーク</td>
            </tr>
            <tr>
              <th>設立</th>
              <td>2000年6月</td>
            </tr>
            <tr>
              <th>代表者</th>
              <td>代表取締役社長 山本 拓真</td>
            </tr>
            <tr>
              <th>事業内容</th>
              <td>介護・医療・子育て支援のクラウドサービス開発・提供</td>
            </tr>
            <tr>
              <th>所在地</th>
              <td>東京都渋谷区恵比寿1-19-19 恵比寿ビジネスタワー</td>
            </tr>
          </table>
        </section>
        
        <section class=\"company-vision\">
          <h2>企業理念</h2>
          <p>人生を抱きしめるクラウド技術で社会に貢献する</p>
          <p>私たちは、介護・医療・子育て支援の分野において、クラウド技術を活用したサービスを提供し、人々の生活の質の向上に貢献します。</p>
        </section>
      </div>
    '
  )
  
  nursing_page = Cms::Page.create!(
    site_id: site.id,
    name: '介護向けシステム',
    filename: 'nursing/index',
    route: 'cms/page',
    state: 'public',
    html: '
      <div class=\"system-info\">
        <h1>介護向けシステム</h1>
        
        <section class=\"system-overview\">
          <h2>システム概要</h2>
          <p>カナミックの介護向けシステムは、介護業務の効率化と質の向上を実現するクラウドサービスです。</p>
          <p>介護記録、ケアプラン作成、請求業務など、介護事業所の業務をトータルにサポートします。</p>
        </section>
        
        <section class=\"system-features\">
          <h2>主な機能</h2>
          <ul>
            <li>介護記録管理</li>
            <li>ケアプラン作成支援</li>
            <li>請求業務効率化</li>
            <li>スタッフ間情報共有</li>
            <li>モバイル対応</li>
          </ul>
        </section>
        
        <section class=\"system-benefits\">
          <h2>導入メリット</h2>
          <p>業務効率化による時間削減</p>
          <p>ペーパーレス化によるコスト削減</p>
          <p>情報共有の円滑化によるケアの質向上</p>
          <p>請求ミス防止による収益改善</p>
        </section>
      </div>
    '
  )
  
  medical_page = Cms::Page.create!(
    site_id: site.id,
    name: '医療向けシステム',
    filename: 'medical/index',
    route: 'cms/page',
    state: 'public',
    html: '
      <div class=\"system-info\">
        <h1>医療向けシステム</h1>
        
        <section class=\"system-overview\">
          <h2>システム概要</h2>
          <p>カナミックの医療向けシステムは、医療機関の業務効率化と患者ケアの質向上を支援するクラウドサービスです。</p>
          <p>診療記録、患者管理、医療連携など、医療機関の業務をトータルにサポートします。</p>
        </section>
        
        <section class=\"system-features\">
          <h2>主な機能</h2>
          <ul>
            <li>診療記録管理</li>
            <li>患者情報管理</li>
            <li>医療連携支援</li>
            <li>スケジュール管理</li>
            <li>モバイル対応</li>
          </ul>
        </section>
        
        <section class=\"system-benefits\">
          <h2>導入メリット</h2>
          <p>業務効率化による時間削減</p>
          <p>ペーパーレス化によるコスト削減</p>
          <p>医療連携の円滑化</p>
          <p>患者ケアの質向上</p>
        </section>
      </div>
    '
  )
  
  childcare_page = Cms::Page.create!(
    site_id: site.id,
    name: '子育て支援システム',
    filename: 'childcare/index',
    route: 'cms/page',
    state: 'public',
    html: '
      <div class=\"system-info\">
        <h1>子育て支援システム</h1>
        
        <section class=\"system-overview\">
          <h2>システム概要</h2>
          <p>カナミックの子育て支援システムは、保育園や子育て支援施設の業務効率化と保育の質向上を支援するクラウドサービスです。</p>
          <p>園児管理、保育記録、保護者連絡など、子育て支援施設の業務をトータルにサポートします。</p>
        </section>
        
        <section class=\"system-features\">
          <h2>主な機能</h2>
          <ul>
            <li>園児情報管理</li>
            <li>保育記録管理</li>
            <li>保護者連絡機能</li>
            <li>スケジュール管理</li>
            <li>モバイル対応</li>
          </ul>
        </section>
        
        <section class=\"system-benefits\">
          <h2>導入メリット</h2>
          <p>業務効率化による時間削減</p>
          <p>ペーパーレス化によるコスト削減</p>
          <p>保護者とのコミュニケーション円滑化</p>
          <p>保育の質向上</p>
        </section>
      </div>
    '
  )
  
  contact_page = Cms::Page.create!(
    site_id: site.id,
    name: 'お問合せ',
    filename: 'contact/index',
    route: 'cms/page',
    state: 'public',
    html: '
      <div class=\"contact-info\">
        <h1>お問合せ</h1>
        
        <section class=\"contact-form\">
          <h2>お問合せフォーム</h2>
          <p>サービスに関するお問合せは、以下のフォームからお願いいたします。</p>
          
          <form>
            <div class=\"form-group\">
              <label for=\"company\">会社名</label>
              <input type=\"text\" id=\"company\" name=\"company\">
            </div>
            
            <div class=\"form-group\">
              <label for=\"name\">お名前</label>
              <input type=\"text\" id=\"name\" name=\"name\">
            </div>
            
            <div class=\"form-group\">
              <label for=\"email\">メールアドレス</label>
              <input type=\"email\" id=\"email\" name=\"email\">
            </div>
            
            <div class=\"form-group\">
              <label for=\"phone\">電話番号</label>
              <input type=\"tel\" id=\"phone\" name=\"phone\">
            </div>
            
            <div class=\"form-group\">
              <label for=\"inquiry\">お問合せ内容</label>
              <textarea id=\"inquiry\" name=\"inquiry\" rows=\"5\"></textarea>
            </div>
            
            <div class=\"form-group\">
              <button type=\"submit\">送信する</button>
            </div>
          </form>
        </section>
        
        <section class=\"contact-info\">
          <h2>お問合せ先</h2>
          <p>株式会社カナミックネットワーク</p>
          <p>〒150-0013 東京都渋谷区恵比寿1-19-19 恵比寿ビジネスタワー</p>
          <p>TEL: 03-XXXX-XXXX</p>
          <p>受付時間: 平日 9:00〜18:00</p>
        </section>
      </div>
    '
  )
  
  uploader_node = Cms::Node.create!(
    site_id: site.id,
    name: 'ファイル',
    filename: 'uploader',
    route: 'uploader/file',
    state: 'public'
  )
  puts "Created uploader node: #{uploader_node.name} (#{uploader_node.id})"
  
  css_dir = "#{site.path}/uploader/css"
  Fs.mkdir_p(css_dir) unless Fs.exist?(css_dir)
  puts "Created CSS directory: #{css_dir}"
  
  css_content = File.read('/app/files/css/kanamic.css')
  css_path = "#{css_dir}/kanamic.css"
  Fs.binwrite(css_path, css_content)
  puts "CSS file uploaded to #{css_path}"
  
  file_model = SS::File.new
  file_model.site_id = site.id
  file_model.model = 'ss/file'
  file_model.name = 'kanamic.css'
  file_model.filename = 'kanamic.css'
  file_model.content_type = 'text/css'
  file_model.path = css_path
  file_model.save!
  puts "File record created in database: #{file_model.name} (#{file_model.id})"
  
  
  layout = Cms::Layout.create!(
    site_id: site.id,
    name: 'カナミックレイアウト',
    filename: 'kanamic_layout',
    html: '
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset=\"UTF-8\">
        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
        <title>{{ page.name }} - カナミック</title>
        <link rel=\"stylesheet\" href=\"/uploader/css/kanamic.css\">
      </head>
      <body>
        <header>
          <div class=\"header-container\">
            <div class=\"logo\">
              <a href=\"/\">カナミック</a>
            </div>
            <nav>
              <ul>
                <li><a href=\"/nursing/\">介護向けシステム</a></li>
                <li><a href=\"/medical/\">医療向けシステム</a></li>
                <li><a href=\"/childcare/\">子育て支援システム</a></li>
                <li><a href=\"/company/\">企業情報</a></li>
                <li><a href=\"/contact/\">お問合せ</a></li>
              </ul>
            </nav>
          </div>
        </header>
        
        <main>
          {{ yield }}
        </main>
        
        <footer>
          <div class=\"footer-container\">
            <div class=\"footer-info\">
              <p>株式会社カナミックネットワーク</p>
              <p>〒150-0013 東京都渋谷区恵比寿1-19-19 恵比寿ビジネスタワー</p>
              <p>&copy; 2025 Kanamic Network Co., Ltd. All Rights Reserved.</p>
            </div>
          </div>
        </footer>
      </body>
      </html>
    '
  )
  
  [top_page, company_page, nursing_page, medical_page, childcare_page, contact_page].each do |page|
    page.layout_id = layout.id
    page.save!
  end
"
