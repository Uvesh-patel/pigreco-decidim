# frozen_string_literal: true

namespace :pigreco do
  namespace :db do
    desc "Run a quick check on the database to verify content counts"
    task quick_check: :environment do
      puts "======= PIGRECO Quick DB Check ======="
      
      # Check organization
      puts "Organizations: #{Decidim::Organization.count}"
      
      # Check processes
      puts "Participatory Processes: #{Decidim::ParticipatoryProcess.count}"
      
      # Check assemblies
      puts "Assemblies: #{Decidim::Assembly.count}"
      
      # Check users
      puts "Users: #{Decidim::User.count}"
      
      # Check components
      puts "Components: #{Decidim::Component.count}"
      
      # Check specific component types
      components = Decidim::Component.all
      component_types = components.group_by(&:manifest_name).transform_values(&:count)
      
      component_types.each do |name, count|
        puts "  - #{name}: #{count}"
      end
      
      puts "======================================"
    end
    
    desc "Run a detailed check on the database content"
    task detailed_check: :environment do
      puts "======= PIGRECO Detailed DB Check ======="
      
      # Verify organization
      organization = Decidim::Organization.first
      if organization
        puts "Organization: #{organization.name}"
        puts "  Host: #{organization.host}"
      else
        puts "ERROR: No organization found!"
      end
      
      # Verify processes
      processes = Decidim::ParticipatoryProcess.all
      puts "\nParticipatory Processes (#{processes.count}):"
      processes.each do |process|
        puts "- #{process.title["en"]}"
        puts "  - Published: #{process.published? ? 'Yes' : 'No'}"
        puts "  - Promoted: #{process.promoted? ? 'Yes' : 'No'}"
        
        # Check components in this process
        components = Decidim::Component.where(participatory_space: process)
        puts "  - Components (#{components.count}):"
        
        components.group_by(&:manifest_name).each do |name, comps|
          puts "    - #{name}: #{comps.count}"
        end
      end
      
      # Verify assemblies
      assemblies = Decidim::Assembly.all
      puts "\nAssemblies (#{assemblies.count}):"
      assemblies.each do |assembly|
        puts "- #{assembly.title["en"]}"
        puts "  - Published: #{assembly.published? ? 'Yes' : 'No'}"
        puts "  - Promoted: #{assembly.promoted? ? 'Yes' : 'No'}"
        
        # Check components in this assembly
        components = Decidim::Component.where(participatory_space: assembly)
        puts "  - Components (#{components.count}):"
        
        components.group_by(&:manifest_name).each do |name, comps|
          puts "    - #{name}: #{comps.count}"
        end
      end
      
      # Verify users
      users = Decidim::User.all
      puts "\nUsers (#{users.count}):"
      puts "- Admin users: #{users.where(admin: true).count}"
      puts "- Regular users: #{users.where(admin: false).count}"
      
      puts "======================================"
    end
  end
end
