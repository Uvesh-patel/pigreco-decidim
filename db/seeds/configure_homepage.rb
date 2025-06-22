# frozen_string_literal: true

# Simple script to configure the homepage content blocks
# This file is placed in the db/seeds directory which is mounted in the container

puts "Configuring homepage content blocks..."

organization = Decidim::Organization.first

# These are the blocks we want to have active
blocks_to_activate = [
  :hero,
  :sub_hero, 
  :highlighted_content_banner,
  :how_to_participate,
  :stats,
  :metrics,
  :highlighted_processes,
  :highlighted_assemblies
]

# Reset the content blocks order to ensure proper order
order = 0
current_blocks = Decidim::ContentBlock.where(
  organization: organization,
  scope_name: :homepage
)
current_blocks.delete_all if current_blocks.any?

blocks_to_activate.each do |block_name|
  # Find or create the content block
  content_block = Decidim::ContentBlock.find_or_initialize_by(
    organization: organization,
    scope_name: :homepage,
    manifest_name: block_name
  )
  
  # Configure the block
  content_block.assign_attributes(
    published_at: Time.current,
    weight: order
  )
  
  # Set default settings for specific blocks
  if block_name == :highlighted_processes || block_name == :highlighted_assemblies
    content_block.settings = content_block.settings.presence || {}
    content_block.settings["max_results"] = 10
  end
  
  # Save the block
  if content_block.save
    puts " - Added content block: #{block_name}"
  else
    puts " - Error adding content block #{block_name}: #{content_block.errors.full_messages.join(', ')}"
  end
  
  order += 1
end

# Make sure all participatory processes are promoted
Decidim::ParticipatoryProcess.all.each do |process|
  next if process.promoted?
  
  process.update(
    promoted: true,
    published_at: Time.current
  )
  puts " - Promoted process: #{process.title["en"]}"
end

# Make sure all assemblies are promoted
Decidim::Assembly.all.each do |assembly|
  next if assembly.promoted?
  
  assembly.update(
    promoted: true,
    published_at: Time.current
  )
  puts " - Promoted assembly: #{assembly.title["en"]}"
end

puts "Homepage configuration completed!"
puts "Please restart the server to see changes."
