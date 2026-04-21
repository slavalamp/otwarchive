class RelatedWorkPolicy < ApplicationPolicy
  ACCESS_UNAPPROVED_ROLES = %w[superadmin policy_and_abuse].freeze

  def access_unapproved?
    user_has_roles?(ACCESS_UNAPPROVED_ROLES)
  end
end
