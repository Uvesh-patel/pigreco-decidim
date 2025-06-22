# frozen_string_literal: true

module Pigreco
  # Service to verify that PIGRECO content is properly seeded and configured
  class ContentVerifier
    # Initialize with the organization
    #
    # @param [Decidim::Organization] organization - The organization to verify
    def initialize(organization)
      @organization = organization
    end

    # Run verification and return results
    #
    # @return [Hash] - Verification results
    def verify
      {
        organization: verify_organization,
        processes: verify_processes,
        assemblies: verify_assemblies,
        components: verify_components,
        content_blocks: verify_content_blocks
      }
    end

    # Print verification results to console
    def print_results
      results = verify
      
      puts "======= PIGRECO CONTENT VERIFICATION ======="
      
      # Organization
      org_results = results[:organization]
      puts "Organization: #{org_results[:name]}"
      
      # Processes
      puts "\nParticipatory Processes (#{results[:processes].size}):"
      results[:processes].each do |p|
        published = p[:published] ? "✓" : "✗"
        promoted = p[:promoted] ? "✓" : "✗"
        puts "- #{p[:title]} [Published: #{published}] [Promoted: #{promoted}]"
      end
      
      # Assemblies
      puts "\nAssemblies (#{results[:assemblies].size}):"
      results[:assemblies].each do |a|
        published = a[:published] ? "✓" : "✗"
        promoted = a[:promoted] ? "✓" : "✗"
        puts "- #{a[:title]} [Published: #{published}] [Promoted: #{promoted}]"
      end
      
      # Components
      puts "\nComponents by type:"
      results[:components].each do |name, count|
        puts "- #{name}: #{count}"
      end
      
      # Content blocks
      puts "\nHomepage Content Blocks (#{results[:content_blocks].size}):"
      results[:content_blocks].each do |b|
        published = b[:published] ? "✓" : "✗"
        puts "- #{b[:name]} [Published: #{published}] [Weight: #{b[:weight]}]"
      end
      
      puts "\n======= VERIFICATION COMPLETE ======="
    end

    private

    attr_reader :organization

    def verify_organization
      {
        name: organization.name,
        host: organization.host
      }
    end

    def verify_processes
      Decidim::ParticipatoryProcess.where(organization: organization).map do |process|
        {
          title: process.title["en"],
          promoted: process.promoted?,
          published: process.published?
        }
      end
    end

    def verify_assemblies
      Decidim::Assembly.where(organization: organization).map do |assembly|
        {
          title: assembly.title["en"],
          promoted: assembly.promoted?,
          published: assembly.published?
        }
      end
    end

    def verify_components
      components = Decidim::Component.where(participatory_space: all_spaces)
      components.group_by(&:manifest_name).transform_values(&:count)
    end

    def verify_content_blocks
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

    def all_spaces
      processes = Decidim::ParticipatoryProcess.where(organization: organization)
      assemblies = Decidim::Assembly.where(organization: organization)
      processes + assemblies
    end
  end
end
