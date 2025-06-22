@echo off
REM PIGRECO Platform Setup and Reset Script for Windows

echo ===== PIGRECO Platform Setup =====

REM Ensure proper directory structure
mkdir storage 2>nul
mkdir log 2>nul

REM Stop containers if running
echo Stopping containers...
docker-compose down

REM Start containers
echo Starting containers...
docker-compose up -d

REM Wait for containers to be ready
echo Waiting for services to be ready...
timeout /t 15 /nobreak > nul

REM Reset database and run migrations before seeding
echo Setting up the database...
docker-compose exec decidim bash -c "cd /code && bundle exec rails db:drop db:create db:migrate db:seed"

echo Running database migrations (this may take a few minutes)...

REM Verify the seeding results
echo Verifying setup...
docker-compose exec decidim bash -c "cd /code && bundle exec rails runner 'Pigreco::DatabaseVerifier.new(Decidim::Organization.first).print_quick_results'"

echo ===== Setup Complete =====
echo You can now access the PIGRECO platform at: http://localhost:3000
echo.
echo Admin user: admin@pigreco.local
echo first time password : decidim123456789
echo Recommended Password after first login (or the one you set): DecidimStrongPassword123!@#

pause
