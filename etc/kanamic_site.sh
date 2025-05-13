
docker-compose run app rake ss:create_site data='{ name: "カナミック", host: "kanamic", domains: "kanamic.localhost:3000" }'

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
  
  css_node = Cms::Node.create!(
    site_id: site.id,
    name: 'CSS',
    filename: 'css',
    route: 'cms/node',
    state: 'public'
  )
  
  css_page = Cms::Page.create!(
    site_id: site.id,
    name: 'kanamic.css',
    filename: 'css/kanamic.css',
    route: 'cms/page',
    state: 'public',
    html: '/* Kanamic style */
body {
  font-family: "Helvetica Neue", Arial, "Hiragino Kaku Gothic ProN", "Hiragino Sans", Meiryo, sans-serif;
  color: #333;
  line-height: 1.6;
}

.main-visual {
  background: linear-gradient(135deg, #ffb347, #ffcc33);
  color: white;
  padding: 80px 20px;
  text-align: center;
}

.main-content h1 {
  font-size: 2.5rem;
  margin-bottom: 20px;
}

.main-content p {
  font-size: 1.2rem;
}

.service-section, .company-section, .contact-section {
  padding: 60px 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.service-section h2, .company-section h2, .contact-section h2 {
  text-align: center;
  margin-bottom: 40px;
  color: #ff9900;
}

.service-items {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
}

.service-item {
  flex: 0 0 30%;
  background: #f9f9f9;
  padding: 30px;
  margin-bottom: 30px;
  border-radius: 5px;
  box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}

.service-item h3 {
  color: #ff9900;
  margin-bottom: 15px;
}

.service-item a {
  display: inline-block;
  margin-top: 15px;
  color: #ff9900;
  text-decoration: none;
  font-weight: bold;
}

.company-section, .contact-section {
  text-align: center;
}

.company-section a, .contact-section a {
  display: inline-block;
  margin-top: 20px;
  background: #ff9900;
  color: white;
  padding: 10px 30px;
  border-radius: 30px;
  text-decoration: none;
  font-weight: bold;
}

/* Company page styles */
.company-info {
  max-width: 800px;
  margin: 0 auto;
  padding: 60px 20px;
}

.company-info h1 {
  text-align: center;
  color: #ff9900;
  margin-bottom: 40px;
}

.company-profile, .company-vision {
  margin-bottom: 60px;
}

.company-profile h2, .company-vision h2 {
  color: #ff9900;
  margin-bottom: 20px;
  border-bottom: 2px solid #ff9900;
  padding-bottom: 10px;
}

.company-profile table {
  width: 100%;
  border-collapse: collapse;
}

.company-profile th, .company-profile td {
  padding: 15px;
  border-bottom: 1px solid #ddd;
}

.company-profile th {
  width: 30%;
  text-align: left;
  color: #666;
}

/* System pages styles */
.system-info {
  max-width: 800px;
  margin: 0 auto;
  padding: 60px 20px;
}

.system-info h1 {
  text-align: center;
  color: #ff9900;
  margin-bottom: 40px;
}

.system-overview, .system-features, .system-benefits {
  margin-bottom: 60px;
}

.system-overview h2, .system-features h2, .system-benefits h2 {
  color: #ff9900;
  margin-bottom: 20px;
  border-bottom: 2px solid #ff9900;
  padding-bottom: 10px;
}

.system-features ul {
  list-style-type: none;
  padding: 0;
}

.system-features li {
  padding: 10px 0;
  border-bottom: 1px dashed #ddd;
}

/* Contact page styles */
.contact-info {
  max-width: 800px;
  margin: 0 auto;
  padding: 60px 20px;
}

.contact-info h1 {
  text-align: center;
  color: #ff9900;
  margin-bottom: 40px;
}

.contact-form, .contact-info {
  margin-bottom: 60px;
}

.contact-form h2, .contact-info h2 {
  color: #ff9900;
  margin-bottom: 20px;
  border-bottom: 2px solid #ff9900;
  padding-bottom: 10px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
}

.form-group input, .form-group textarea {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 5px;
}

.form-group button {
  background: #ff9900;
  color: white;
  padding: 10px 30px;
  border: none;
  border-radius: 30px;
  font-weight: bold;
  cursor: pointer;
}',
    format: 'text/css'
  )
  
  layout = Cms::Layout.create!(
    site_id: site.id,
    name: 'カナミックレイアウト',
    html: '
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset=\"UTF-8\">
        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
        <title>{{ page.name }} - カナミック</title>
        <link rel=\"stylesheet\" href=\"/css/kanamic.css\">
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
