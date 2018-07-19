class DealCollaborator < ActiveRecord::Base
  # Associations
  belongs_to :deal
  belongs_to :user

  def to_hash
    return self.user.to_hash(false)
  end
end
