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

top_node = Cms::Node.create!(
  site_id: site.id,
  name: 'トップページ',
  filename: 'index',
  route: 'cms/node',
  state: 'public'
)

# Create file node for backend visibility
file_node = Cms::Node.create!(
  site_id: site.id,
  filename: 'files',
  name: 'ファイル',
  route: 'uploader/file',
  state: 'public'
)
puts "Created file node: #{file_node.name} (#{file_node.id})"

puts "Kanamic site initialized successfully!"
