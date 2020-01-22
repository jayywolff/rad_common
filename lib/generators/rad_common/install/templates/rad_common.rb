RadCommon.setup do |config|
  # Enables/Disables user avatars being uploaded and displayed in the application
  # config.use_avatar = false
  #
  # Does not allow users to manually sign up
  # config.disable_sign_up = false
  #
  # Allows users to be marked as external/client users, adjusts user filtering and seeds to account for this
  # config.external_users = false
  #
  # Allows for two-factor authentication to be enabled for users
  # config.authy_user_opt_in = false
  #
  # Only includes company name in email header if app logo does not include name
  # config.app_logo_includes_name = true
  #
  # Set to namespace for portal users. This is needed to control authentication.
  # config.portal_namespace = nil
  #
  # Determines which models should be included in the system_usages route
  # config.system_usage_models = []
  #
  # Determines which attributes should be hidden in the audits for non-admin users
  # config.restricted_audit_attributes = []
  #
  # allows for additional parameters to be passed into the users controller thus
  # avoiding the need to override the controller in many cases)
  # config.additional_user_params = []
  #
  # Determines how ofter the global validity check will run
  # config.global_validity_days = 3
  #
  # Sets the time allowed for the global validity to run before timing out / raising an error
  # config.global_validity_timeout = 3.hours
  #
  # Determines models to be excluded in the global validity check
  # config.global_validity_exclude = []
  #
  # Allows for queries to be passed in, providing the ability to exclude records of specific class
  # This is typically used in combination with global_validity_exclude
  # config.global_validity_include = []
  #
  # Allows for specific messages to be excluded from the global validity emailed result
  # config.global_validity_supress = []
  #
  # Allows for manual trigger of global validity check on the company show page
  # config.global_validity_enable_interactive = true
  #
  # Sets search scopes to be included in the navigation search bar
  # config.global_search_scopes = []
end
