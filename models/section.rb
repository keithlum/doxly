class Section < ActiveRecord::Base
  # Associations
  belongs_to :sectionable,    :polymorphic => true
  belongs_to :creator, foreign_key: :created_by, class_name: 'User'
  has_many   :folders
  has_many   :tasks
  has_many   :documents, :as => :documentable
  has_many   :comments,       :as => :commentable
  
  def to_hash
    data = {
      section_id:  self.id,
      name:        self.name,
      category_id: self.category_id,
      activated:   self.activated
    }

    if self.deal_id
      data[:deal] = self.deal.to_hash
    end

    if self.creator
      data[:creator] = self.creator.to_hash(false)
    end

    return data
  end
end

