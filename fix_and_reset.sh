#!/bin/bash

echo "===== PIGRECO Database Reset and Fix ====="

# Stop containers if running
echo "Stopping containers..."
docker-compose down

# Start database only
echo "Starting database..."
docker-compose up -d db

# Wait for database to be ready
echo "Waiting for database to be ready..."
sleep 10

# Start decidim container
echo "Starting Decidim container..."
docker-compose up -d decidim

# Wait for decidim to be ready
echo "Waiting for Decidim to be ready..."
sleep 10

# Reset database
echo "Resetting database..."
docker-compose exec decidim bash -c "cd /code && bundle exec rails db:reset"

# Run configuration script
echo "Configuring homepage..."
docker-compose exec decidim bash -c "cd /code && bundle exec rails runner /code/db/seeds/configure_homepage.rb"

# Verify content
echo "Verifying content..."
docker-compose exec decidim bash -c "cd /code && bundle exec rails runner /code/db/seeds/verify_content.rb"

echo "===== Fix Complete ====="
echo "You can now access the Decidim platform at: http://localhost:3000"
