class Category < ActiveRecord::Base
  self.inheritance_column = 'name'

  # Validations
  validates(
    :name,
    length:{
      maximum: 100
    }
  )

  belongs_to :deal
  has_many   :comments, :as => :commentable
  has_many   :sections, :as => :sectionable
end
