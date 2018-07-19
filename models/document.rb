class Document < ActiveRecord::Base
  #Associations
  has_many :document_signers
  has_many :users, through: :document_signers
  has_many :comments, as: :commentable

  belongs_to :creator, foreign_key: :created_by, class_name: 'User'
  belongs_to :parent, polymorphic: true
  belongs_to :deal

  after_create :set_deal_id

  def set_deal_id
    unless deal_id
      self.deal_id = parent.deal_id
      save
    end
  end

  def to_hash
    data = {
      document_id:      self.id,
      title:            self.title,
      file_name:        self.file_name,
      file_size:        self.file_size,
      file_type:        self.file_type,
      file_uploaded_at: self.file_uploaded_at,
      parent_type:      self.parent_type,
      parent_id:        self.parent_id,
      activated:        self.activated
    }

    if self.creator
      data[:creator] = self.creator.to_hash(false)
    end

    return data
  end
end
