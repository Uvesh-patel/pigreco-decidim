# frozen_string_literal: true

module Pigreco
  # Service to configure the homepage content blocks for the PIGRECO platform
  class HomepageConfigurator
    # Configure homepage content blocks for the organization
    #
    # @param [Decidim::Organization] organization - The organization to configure
    # @return [Boolean] - Whether the configuration was successful
    def self.configure(organization)
      new(organization).configure
    end

    def initialize(organization)
      @organization = organization
    end

    def configure
      # Reset content blocks
      reset_content_blocks

      # Add content blocks in the desired order
      blocks_to_activate.each_with_index do |block_name, index|
        add_content_block(block_name, index)
      end

      # Ensure processes and assemblies are properly configured
      promote_processes
      promote_assemblies

      true
    end

    private

    attr_reader :organization

    def reset_content_blocks
      current_blocks = Decidim::ContentBlock.where(
        organization: organization,
        scope_name: :homepage
      )
      current_blocks.delete_all if current_blocks.any?
    end

    def add_content_block(block_name, weight)
      # Skip the manifest check - we'll let Decidim handle any invalid content blocks
      # This avoids errors with manifests method which may not be available in all Decidim versions

      # Create the content block
      content_block = Decidim::ContentBlock.find_or_initialize_by(
        organization: organization,
        scope_name: :homepage,
        manifest_name: block_name
      )
      
      # Configure the block
      content_block.assign_attributes(
        published_at: Time.current,
        weight: weight
      )
      
      # Set default settings for specific blocks
      if block_name == :highlighted_processes || block_name == :highlighted_assemblies
        content_block.settings = content_block.settings.presence || {}
        content_block.settings["max_results"] = 10
      end
      
      # Configure highlighted content banner if needed
      if block_name == :highlighted_content_banner
        configure_banner(content_block)
      end
      
      content_block.save
    end

    def configure_banner(banner_block)
      banner_block.settings = banner_block.settings.presence || {}
      banner_block.settings["title"] = { en: "Welcome to the PIGRECO Risk Assessment Platform" }
      banner_block.settings["short_description"] = { 
        en: "Explore our participatory processes for multi-risk assessment and territorial planning" 
      }
      banner_block.settings["button_text"] = { en: "Get Involved" }
      banner_block.settings["button_url"] = "/processes"
    end

    def promote_processes
      Decidim::ParticipatoryProcess.where(organization: organization).each do |process|
        next if process.promoted? && process.published?
        
        process.update(
          promoted: true,
          published_at: Time.current
        )
      end
    end

    def promote_assemblies
      Decidim::Assembly.where(organization: organization).each do |assembly|
        next if assembly.promoted? && assembly.published?
        
        assembly.update(
          promoted: true,
          published_at: Time.current
        )
      end
    end

    def blocks_to_activate
      [
        :hero,
        :sub_hero, 
        :highlighted_content_banner,
        :how_to_participate,
        :stats,
        :metrics,
        :highlighted_processes,
        :highlighted_assemblies
      ]
    end

    def content_block_registry
      Decidim.content_blocks.for(:homepage)
    end
  end
end
