#!/bin/bash
# PIGRECO Platform Setup and Reset Script

echo "===== PIGRECO Platform Setup ====="

# Ensure proper directory structure
mkdir -p storage log

# Stop containers if running
echo "Stopping containers..."
docker-compose down

# Start containers
echo "Starting containers..."
docker-compose up -d

# Wait for containers to be ready
echo "Waiting for services to be ready..."
sleep 15

# Reset database and run migrations before seeding
echo "Setting up the database..."
docker-compose exec decidim bash -c "cd /code && bundle exec rails db:drop db:create db:migrate db:seed"

echo "Running database migrations (this may take a few minutes)..."

# Verify the seeding results
echo "Verifying setup..."
docker-compose exec decidim bash -c "cd /code && bundle exec rails runner 'Pigreco::DatabaseVerifier.new(Decidim::Organization.first).print_quick_results'"

# Configure PIGRECO components if needed
echo "Final configuration..."
docker-compose exec decidim bash -c "cd /code && bundle exec rails runner 'Pigreco::HomepageConfigurator.configure(Decidim::Organization.first)'"

echo "===== Setup Complete ====="
echo "You can now access the PIGRECO platform at: http://localhost:3000"
echo ""
echo "Admin user: admin@pigreco.local"
echo "Password: decidim123456"
