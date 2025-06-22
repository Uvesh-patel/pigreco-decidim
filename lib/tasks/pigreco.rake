# frozen_string_literal: true

namespace :pigreco do
  desc "Configure PIGRECO homepage and ensure content is properly displayed"
  task configure_homepage: :environment do
    puts "Configuring PIGRECO homepage..."
    organization = Decidim::Organization.first
    
    if organization
      if Pigreco::HomepageConfigurator.configure(organization)
        puts "Homepage configuration completed successfully!"
      else
        puts "Error configuring homepage"
      end
    else
      puts "No organization found! Please run 'rails db:seed' first."
    end
  end

  desc "Verify PIGRECO content and configuration"
  task verify_content: :environment do
    organization = Decidim::Organization.first
    
    if organization
      verifier = Pigreco::ContentVerifier.new(organization)
      verifier.print_results
    else
      puts "No organization found! Please run 'rails db:seed' first."
    end
  end

  desc "Reset database and configure PIGRECO platform"
  task setup: :environment do
    puts "===== Setting up PIGRECO platform ====="
    
    if ENV["CONFIRM_RESET"] == "yes"
      Rake::Task["db:reset"].invoke
      puts "Database reset complete."
      
      Rake::Task["pigreco:configure_homepage"].invoke
      Rake::Task["pigreco:verify_content"].invoke
      
      puts "===== PIGRECO setup complete ====="
      puts "Access the platform at: http://localhost:3000"
    else
      puts "This task will RESET THE DATABASE and lose all data!"
      puts "To confirm, run: rake pigreco:setup CONFIRM_RESET=yes"
    end
  end
end
