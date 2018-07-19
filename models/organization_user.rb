class OrganizationUser < ActiveRecord::Base
  # Associations
  belongs_to :user
  belongs_to :organization

  has_many :collaborators, :as => :collaboratable
end
