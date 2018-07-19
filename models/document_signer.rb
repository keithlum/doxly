class DocumentSigner < ActiveRecord::Base
  # Associations
  belongs_to :document
  belongs_to :user

  def to_hash
    return self.document.to_hash
  end
end
