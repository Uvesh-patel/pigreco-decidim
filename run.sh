#!/usr/bin/env bash
set -euo pipefail

# PIGRECO Platform Setup
echo "🌱 Setting up PIGRECO platform..."

# Ensure temp directory exists with subdirectories
mkdir -p temp/db_data temp/storage temp/scripts

# Create necessary directories
mkdir -p app/views/layouts/decidim/footer
mkdir -p config/locales
mkdir -p db/seeds
mkdir -p assets

# Clean environment
echo "🧹 Cleaning environment…"
docker-compose down -v
docker system prune --volumes --force

# Start Docker containers
echo "🐳 Starting Docker containers..."
docker-compose up -d

# Wait for services to come up
echo "⏳ Waiting for services to start..."
sleep 10

# Setup database
echo "💎 Setting up database and running migrations…"
docker-compose exec decidim bash -c "
  echo 'Creating and migrating database...' &&
  bundle exec rails db:create db:migrate"

# Seed the database with PIGRECO content
echo "🌿 Seeding PIGRECO content..."
docker-compose exec decidim bash -c "cd /code && bundle exec rails db:seed"

# Create admin user if needed
echo "👤 Ensuring admin user exists..."
docker-compose exec decidim bash -c "cd /code && bundle exec rails decidim_system:create_admin --email=admin@pigreco.local --password=decidim123456 || echo 'Admin may already exist'"

# Create smoke test script
echo "🔍 Creating smoke test script..."
cat > temp/scripts/smoke_test.rb << 'EOL'
# Smoke test script to verify PIGRECO content
puts "===== PIGRECO Smoke Test ====="

# Check organization
org = Decidim::Organization.first
if org&.name == "PIGRECO Platform"
  puts "✓ Organization exists and is properly named"
else
  puts "✗ Organization issue - name is #{org&.name || 'missing'}"
end

# Check participatory process
process = Decidim::ParticipatoryProcess.find_by(slug: "multi-risk-assessment")
if process
  puts "✓ PIGRECO participatory process exists"
else
  puts "✗ PIGRECO participatory process missing"
end

# Check assembly
assembly = Decidim::Assembly.find_by(slug: "risk-governance-assembly")
if assembly
  puts "✓ PIGRECO assembly exists"
else
  puts "✗ PIGRECO assembly missing"
end

# Check proposals
proposals = Decidim::Proposals::Proposal.all
if proposals.count > 0
  puts "✓ Found #{proposals.count} proposals"
else
  puts "✗ No proposals found"
end

# Check meetings
meetings = Decidim::Meetings::Meeting.all
if meetings.count > 0
  puts "✓ Found #{meetings.count} meetings"
else
  puts "✗ No meetings found"
end

puts "===== Smoke Test Complete ====="
EOL

# Run smoke test to verify content
echo "🧪 Running smoke test to verify content..."
docker-compose exec decidim bash -c "cd /code && bundle exec rails runner /code/temp/scripts/smoke_test.rb"

# Final message
echo "✅ PIGRECO Setup Complete"
echo "PIGRECO is live at http://localhost:3000"
echo "System panel at http://localhost:3000/system"
echo "System admin credentials:"
echo "  Email: system@pigreco.local"
echo "  Password: decidim123456"
echo "Platform admin credentials:"
echo "  Email: admin@pigreco.local"
echo "  Password: decidim123456"
echo "ℹ️ Note: To customize PIGRECO branding, add images to the assets directory"
