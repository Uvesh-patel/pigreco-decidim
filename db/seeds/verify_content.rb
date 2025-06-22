# frozen_string_literal: true

# Simple verification script to check if content is properly seeded
puts "======= PIGRECO CONTENT VERIFICATION ======="

org = Decidim::Organization.first
puts "Organization: #{org.name}" if org

# Check processes
processes = Decidim::ParticipatoryProcess.all
puts "\nParticipatory Processes (#{processes.count}):"
processes.each do |p|
  published = p.published? ? "✓" : "✗"
  promoted = p.promoted? ? "✓" : "✗"
  puts "- #{p.title["en"]} [Published: #{published}] [Promoted: #{promoted}]"
end

# Check assemblies
assemblies = Decidim::Assembly.all
puts "\nAssemblies (#{assemblies.count}):"
assemblies.each do |a|
  published = a.published? ? "✓" : "✗"
  promoted = a.promoted? ? "✓" : "✗"
  puts "- #{a.title["en"]} [Published: #{published}] [Promoted: #{promoted}]"
end

# Check components
components = Decidim::Component.all
puts "\nComponents (#{components.count}):"
components.group_by(&:manifest_name).each do |name, comps|
  puts "- #{name}: #{comps.count}"
end

# Check content blocks
blocks = Decidim::ContentBlock.where(scope_name: :homepage)
puts "\nHomepage Content Blocks (#{blocks.count}):"
blocks.order(:weight).each do |b|
  published = b.published? ? "✓" : "✗"
  puts "- #{b.manifest_name} [Published: #{published}] [Weight: #{b.weight}]"
end

puts "\n======= VERIFICATION COMPLETE ======="
