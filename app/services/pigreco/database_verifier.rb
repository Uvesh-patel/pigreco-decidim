# frozen_string_literal: true

module Pigreco
  # Service to verify the database content for the PIGRECO platform
  class DatabaseVerifier
    # Initialize with the organization
    #
    # @param [Decidim::Organization] organization - The organization to verify
    def initialize(organization)
      @organization = organization
    end

    # Run a quick verification and return results
    #
    # @return [Hash] - Verification results with counts
    def quick_verify
      {
        organization: organization.present?,
        processes_count: processes.count,
        assemblies_count: assemblies.count, 
        users_count: users.count,
        components_count: components.count,
        component_types: component_types
      }
    end

    # Run a comprehensive verification and return detailed results
    #
    # @return [Hash] - Detailed verification results
    def detailed_verify
      {
        organization: organization_details,
        processes: process_details,
        assemblies: assembly_details,
        users: user_details,
        components: component_details,
        content_blocks: content_block_details
      }
    end

    # Print quick verification results to console
    def print_quick_results
      results = quick_verify
      
      puts "======= PIGRECO Quick DB Check ======="
      puts "Organization: #{results[:organization] ? 'Found' : 'Not found!'}"
      puts "Participatory Processes: #{results[:processes_count]}"
      puts "Assemblies: #{results[:assemblies_count]}"
      puts "Users: #{results[:users_count]}"
      puts "Components: #{results[:components_count]}"
      
      puts "\nComponent types:"
      results[:component_types].each do |name, count|
        puts "  - #{name}: #{count}"
      end
      
      puts "======================================"
    end

    # Print detailed verification results to console
    def print_detailed_results
      results = detailed_verify
      
      puts "======= PIGRECO Detailed DB Check ======="
      
      # Organization
      org = results[:organization]
      puts "Organization: #{org[:name]}"
      puts "  Host: #{org[:host]}"
      
      # Processes
      puts "\nParticipatory Processes (#{results[:processes].size}):"
      results[:processes].each do |p|
        puts "- #{p[:title]}"
        puts "  - Published: #{p[:published] ? 'Yes' : 'No'}"
        puts "  - Promoted: #{p[:promoted] ? 'Yes' : 'No'}"
        puts "  - Components:"
        
        p[:components].each do |name, count|
          puts "    - #{name}: #{count}"
        end
      end
      
      # Assemblies
      puts "\nAssemblies (#{results[:assemblies].size}):"
      results[:assemblies].each do |a|
        puts "- #{a[:title]}"
        puts "  - Published: #{a[:published] ? 'Yes' : 'No'}"
        puts "  - Promoted: #{a[:promoted] ? 'Yes' : 'No'}"
        puts "  - Components:"
        
        a[:components].each do |name, count|
          puts "    - #{name}: #{count}"
        end
      end
      
      # Users
      puts "\nUsers:"
      puts "- Admin users: #{results[:users][:admin_count]}"
      puts "- Regular users: #{results[:users][:regular_count]}"
      
      # Content blocks
      puts "\nHomepage Content Blocks (#{results[:content_blocks].size}):"
      results[:content_blocks].each do |b|
        published = b[:published] ? "✓" : "✗"
        puts "- #{b[:name]} [Published: #{published}] [Weight: #{b[:weight]}]"
      end
      
      puts "======================================"
    end

    private

    attr_reader :organization

    def organization_details
      {
        name: organization.name,
        host: organization.host,
        available_locales: organization.available_locales,
        default_locale: organization.default_locale
      }
    end

    def process_details
      processes.map do |process|
        components = Decidim::Component.where(participatory_space: process)
        component_counts = components.group_by(&:manifest_name).transform_values(&:count)
        
        {
          title: process.title["en"],
          promoted: process.promoted?,
          published: process.published?,
          components: component_counts
        }
      end
    end

    def assembly_details
      assemblies.map do |assembly|
        components = Decidim::Component.where(participatory_space: assembly)
        component_counts = components.group_by(&:manifest_name).transform_values(&:count)
        
        {
          title: assembly.title["en"],
          promoted: assembly.promoted?,
          published: assembly.published?,
          components: component_counts
        }
      end
    end

    def user_details
      {
        total_count: users.count,
        admin_count: users.where(admin: true).count,
        regular_count: users.where(admin: false).count
      }
    end

    def component_details
      components.group_by(&:manifest_name).transform_values(&:count)
    end

    def content_block_details
      Decidim::ContentBlock.where(
        organization: organization,
        scope_name: :homepage
      ).order(:weight).map do |block|
        {
          name: block.manifest_name,
          published: block.published?,
          weight: block.weight
        }
      end
    end

    def processes
      @processes ||= Decidim::ParticipatoryProcess.where(organization: organization)
    end

    def assemblies
      @assemblies ||= Decidim::Assembly.where(organization: organization)
    end

    def users
      @users ||= Decidim::User.where(organization: organization)
    end

    def components
      @components ||= Decidim::Component.where(participatory_space: all_spaces)
    end

    def all_spaces
      processes + assemblies
    end

    def component_types
      components.group_by(&:manifest_name).transform_values(&:count)
    end
  end
end
