class StarredDeal < ActiveRecord::Base
  # Validations
  validates(
    :deal_id,
    presence: true,
    uniqueness:{
      scope: :user_id
    }
  )
  validates(
    :user_id,
    presence: true
  )
  # Associations
  belongs_to :deal
  belongs_to :user

  def to_hash
    return self.deal.to_hash
  end
end
