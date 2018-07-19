class Notification < ActiveRecord::Base
  # Associations
  belongs_to :user

  def to_hash
    data = {
      notification_id: self.id,
      message:         self.message,
      status:          self.status
    }
    if self.user
      data[:user] = self.user.to_hash(false)
    end

    return data
  end
end
