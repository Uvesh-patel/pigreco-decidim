# frozen_string_literal: true

namespace :pigreco do
  namespace :homepage do
    desc "Configure the homepage with all necessary content blocks"
    task configure: :environment do
      organization = Decidim::Organization.first
      
      unless organization
        puts "ERROR: No organization found!"
        next
      end
      
      puts "Configuring homepage for organization: #{organization.name}"
      
      begin
        Pigreco::HomepageConfigurator.configure(organization)
        puts "Homepage configured successfully!"
      rescue => e
        puts "ERROR configuring homepage: #{e.message}"
        puts e.backtrace.join("\n")
      end
    end
    
    desc "Verify the homepage configuration"
    task verify: :environment do
      organization = Decidim::Organization.first
      
      unless organization
        puts "ERROR: No organization found!"
        next
      end
      
      puts "Verifying homepage configuration for: #{organization.name}"
      
      content_blocks = Decidim::ContentBlock.where(
        organization: organization,
        scope_name: :homepage
      ).order(:weight)
      
      if content_blocks.any?
        puts "Found #{content_blocks.count} content blocks:"
        
        content_blocks.each do |block|
          status = block.published? ? "✓ Published" : "✗ Not published"
          puts "- #{block.manifest_name} [#{status}] (Weight: #{block.weight})"
        end
      else
        puts "WARNING: No content blocks found for homepage!"
      end
    end
    
    desc "Reset homepage configuration to PIGRECO defaults"
    task reset: :environment do
      organization = Decidim::Organization.first
      
      unless organization
        puts "ERROR: No organization found!"
        next
      end
      
      puts "Resetting homepage configuration for: #{organization.name}"
      
      # Delete existing content blocks
      content_blocks = Decidim::ContentBlock.where(
        organization: organization,
        scope_name: :homepage
      )
      
      if content_blocks.any?
        count = content_blocks.count
        content_blocks.destroy_all
        puts "Deleted #{count} existing content blocks"
      else
        puts "No existing content blocks to delete"
      end
      
      # Reconfigure homepage
      begin
        Pigreco::HomepageConfigurator.configure(organization)
        puts "Homepage reset and configured successfully!"
      rescue => e
        puts "ERROR resetting homepage: #{e.message}"
        puts e.backtrace.join("\n")
      end
    end
  end
end
