# frozen_string_literal: true

namespace :pigreco do
  namespace :test do
    desc "Run all content validation tests"
    task all: [:content_counts, :homepage_config, :seed_verification]

    desc "Validate content counts in the database"
    task content_counts: :environment do
      puts "=== Validating Content Counts ==="
      organization = Decidim::Organization.first
      
      unless organization
        puts "ERROR: No organization found!"
        next
      end
      
      verifier = Pigreco::DatabaseVerifier.new(organization)
      verifier.print_quick_results
    end
    
    desc "Validate homepage configuration"
    task homepage_config: :environment do
      puts "=== Validating Homepage Configuration ==="
      organization = Decidim::Organization.first
      
      unless organization
        puts "ERROR: No organization found!"
        next
      end
      
      # Check content blocks on homepage
      puts "\nContent blocks on homepage:"
      blocks = Decidim::ContentBlock.where(
        organization: organization,
        scope_name: :homepage
      ).order(:weight)
      
      if blocks.any?
        blocks.each do |block|
          published = block.published? ? "✓" : "✗"
          puts " - #{block.manifest_name} (#{published})"
        end
      else
        puts " No content blocks found!"
      end
      
      # Check highlighted content banner
      banner = Decidim::ContentBlock.find_by(
        organization: organization,
        scope_name: :homepage,
        manifest_name: :highlighted_content_banner
      )
      
      if banner
        puts "\nHighlighted content banner is configured."
      else
        puts "\nWARNING: Highlighted content banner is not configured!"
      end
      
      # Check highlighted processes content block
      processes_block = Decidim::ContentBlock.find_by(
        organization: organization,
        scope_name: :homepage,
        manifest_name: :highlighted_processes
      )
      
      if processes_block
        puts "Highlighted processes block is configured."
        puts "  - Max results: #{processes_block.settings.try(:[], 'max_results')}"
      else
        puts "WARNING: Highlighted processes block is not configured!"
      end
      
      # Check highlighted assemblies content block
      assemblies_block = Decidim::ContentBlock.find_by(
        organization: organization,
        scope_name: :homepage,
        manifest_name: :highlighted_assemblies
      )
      
      if assemblies_block
        puts "Highlighted assemblies block is configured."
        puts "  - Max results: #{assemblies_block.settings.try(:[], 'max_results')}"
      else
        puts "WARNING: Highlighted assemblies block is not configured!"
      end
    end
    
    desc "Verify seed data"
    task seed_verification: :environment do
      puts "=== Verifying Seed Data ==="
      organization = Decidim::Organization.first
      
      unless organization
        puts "ERROR: No organization found!"
        next
      end
      
      verifier = Pigreco::DatabaseVerifier.new(organization)
      verifier.print_detailed_results
    end
  end
end
