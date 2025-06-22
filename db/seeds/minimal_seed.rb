# frozen_string_literal: true

puts "==== PIGRECO Minimal Seed Started ===="

# Create System Admin account
puts "Creating system admin..."
begin
  system_admin = Decidim::System::Admin.find_or_initialize_by(email: "system@pigreco.local")
  system_admin.update!(password: "decidim123456", password_confirmation: "decidim123456")
  puts "System admin created"
rescue => e
  puts "Error creating system admin: #{e.message}"
end

# Create basic organization - use SQL to avoid potential model incompatibilities
puts "Creating PIGRECO organization..."
begin
  organization = nil
  org = Decidim::Organization.find_by(host: "localhost")
  
  if org
    puts "Organization already exists"
    organization = org
  else
    # Create using only the most basic attributes
    org = Decidim::Organization.new
    org.name = "PIGRECO"
    org.host = "localhost"
    org.default_locale = "en"
    org.available_locales = ["en"]
    
    # Try to save with default validations
    if org.save
      puts "Organization created"
      organization = org
    else
      puts "Failed to create organization: #{org.errors.full_messages.join(', ')}"
    end
  end
  
  # Only proceed with admin user if we have an organization
  if organization
    # Create admin user
    puts "Creating admin user..."
    admin = Decidim::User.find_by(email: "admin@pigreco.local", organization: organization)
    
    if admin
      puts "Admin user already exists"
    else
      admin = Decidim::User.new(
        email: "admin@pigreco.local",
        name: "PIGRECO Admin",
        nickname: "pigreco_admin",
        password: "decidim123456",
        password_confirmation: "decidim123456",
        organization: organization,
        confirmed_at: Time.current,
        locale: "en",
        admin: true,
        tos_agreement: true
      )
      
      if admin.save
        puts "Admin user created"
      else
        puts "Failed to create admin user: #{admin.errors.full_messages.join(', ')}"
      end
    end
  end
rescue => e
  puts "Error in seed process: #{e.message}"
  puts e.backtrace.join("\n")
end

puts "==== PIGRECO Minimal Seed Completed ===="
