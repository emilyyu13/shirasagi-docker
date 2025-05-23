docker-compose run app rake ss:create_site data='{ name: "自治体サンプル", host: "demo", domains: "demo.localhost:3000" }'
docker-compose run app rake db:seed site=demo name=demo
docker-compose run app rake ss:create_site data='{ name: "企業サンプル", host: "company", domains: "company.localhost:3000" }'
docker-compose run app rake db:seed site=company name=company
docker-compose run app rake ss:create_site data='{ name: "子育て支援サンプル", host: "childcare", domains: "childcare.localhost:3000" }'
docker-compose run app rake db:seed site=childcare name=childcare
docker-compose run app rake ss:create_site data='{ name: "オープンデータサンプル", host: "opendata", domains: "opendata.localhost:3000" }'
docker-compose run app rake db:seed site=opendata name=opendata
docker-compose run app rake ss:create_site data='{ name: "LPサンプル", host: "lp1", domains: "lp.localhost:3000" }'
docker-compose run app rake db:seed site=lp name=lp1
