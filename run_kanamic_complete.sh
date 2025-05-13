
echo "Starting complete Kanamic site creation with CSS file visibility fix..."

docker-compose exec app bundle exec rails r /app/etc/kanamic_site_complete.rb

echo "Kanamic site creation completed!"
echo "You can now access the site at http://kanamic.localhost:3000"
echo "To view the CSS file in the backend, go to http://localhost:3000/.s2/cms/contents and click on 'フォルダー'"
