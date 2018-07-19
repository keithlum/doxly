class Folder < ApplicationRecord
  # Association
  belongs_to :user, foreign_key: :created_by
  belongs_to :parent, polymorphic: true
  belongs_to :deal

  has_many :documents, as: :documentable
  has_many :comments, as: :commentable

  after_create :set_deal_id

  def set_deal_id
    unless deal_id
      self.deal_id = parent.deal_id
      save
    end
  end

  def to_hash
    data = {
      name:        self.name,
      parent_type: self.parent_type,
      parent_id:   self.parent_id,
      activated:   self.activated
    }

    if self.user
      data[:creator] = self.user.to_hash(false)
    end

    return data
  end

  def deal
    Deal.find(parent.deal_id)
  end
end
