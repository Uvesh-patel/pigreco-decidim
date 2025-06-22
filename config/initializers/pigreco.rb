# frozen_string_literal: true

# PIGRECO Platform configuration
#
# This initializer sets up custom configurations for the PIGRECO platform

Rails.application.config.to_prepare do
  # Add any custom configurations here that should be loaded at application startup
  
  # Make sure our custom service classes are autoloaded
  Rails.autoloaders.main.push_dir(Rails.root.join("app", "services", "pigreco"))
end
