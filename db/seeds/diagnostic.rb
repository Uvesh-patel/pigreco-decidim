# frozen_string_literal: true

# Diagnostic script to check current state of the database
puts "=== PIGRECO DIAGNOSTIC TOOL ==="
puts "Checking current database state..."

# Check organizations
orgs = Decidim::Organization.all
puts "Organizations found: #{orgs.count}"
orgs.each do |org|
  puts "  - #{org.name} (Host: #{org.host}, Created: #{org.created_at})"
end

# Get the default organization
organization = Decidim::Organization.first
if organization
  puts "\nDefault organization: #{organization.name} (#{organization.host})"
  
  # Check participatory processes
  processes = Decidim::ParticipatoryProcess.where(organization: organization)
  puts "\nParticipatory processes found: #{processes.count}"
  processes.each do |p|
    puts "  - #{p.title["en"]} (Slug: #{p.slug}, Published: #{p.published?})"
  end
  
  # Check assemblies
  assemblies = Decidim::Assembly.where(organization: organization)
  puts "\nAssemblies found: #{assemblies.count}"
  assemblies.each do |a|
    puts "  - #{a.title["en"]} (Slug: #{a.slug}, Published: #{a.published?})"
  end
  
  # Check components
  components = Decidim::Component.where(participatory_space: processes + assemblies)
  puts "\nComponents found: #{components.count}"
  components.each do |c|
    puts "  - #{c.name["en"]} (#{c.manifest_name}) for #{c.participatory_space_type} #{c.participatory_space_id}"
  end
  
  # Check proposals
  if defined?(Decidim::Proposals::Proposal)
    proposals = Decidim::Proposals::Proposal.joins(:component).where(decidim_components: { organization_id: organization.id })
    puts "\nProposals found: #{proposals.count}"
    proposals.each do |prop|
      puts "  - #{prop.title["en"]} (State: #{prop.state})"
    end
  else
    puts "\nProposals module not available"
  end
  
  # Check meetings
  if defined?(Decidim::Meetings::Meeting)
    meetings = Decidim::Meetings::Meeting.joins(:component).where(decidim_components: { organization_id: organization.id })
    puts "\nMeetings found: #{meetings.count}"
    meetings.each do |m|
      puts "  - #{m.title["en"]} (#{m.start_time})"
    end
  else
    puts "\nMeetings module not available"
  end
else
  puts "No organizations found in the database!"
end

puts "\n=== DIAGNOSTIC COMPLETE ==="
