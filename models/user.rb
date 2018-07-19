class User < ActiveRecord::Base
  include DealOwner

  ROLES = ["Normal", "Super"]

  devise(
    :database_authenticatable,
    :registerable,
    :recoverable,
    :rememberable,
    :trackable,
    :validatable,
    :confirmable
  )

  # Validations
  validates(
    :email,
    presence: true
  )
  validates(
    :first_name,
    presence: true
  )
  validates(
    :last_name,
    presence: true
  )
  validates(
    :phone,
    allow_blank: true,
    length:{
      maximum: 15
    }
  )
  validates(
    :company,
    allow_blank: true,
    length:{
      maximum: 100
    }
  )
  validates(
    :role,
    presence: true,
    inclusion: {
      in: [USER_SUPER, USER_NORMAL],
      message: "%{value} is not a valid role"
    }
  )

  #Associations
  has_one  :organization_user, dependent: :destroy
  has_one  :organization,      through: :organization_user
  has_many :document_signers
  has_many :documents, through: :document_signers
  has_many :comments
  has_many :deal_collaborators
  has_many :deals, through: :deal_collaborators
  has_many :notifications
  has_many :starred_deals
  has_many :tasks, foreign_key: :created_by
  has_many :folders, foreign_key: :created_by
  has_many :sections, foreign_key: :created_by


  def is_organization_admin?(organization_id)
    return true if self.is_super?

    organization_user = OrganizationUser.where(
      user_id: self.id,
      organization_id: organization_id,
      user_type: ORG_USER_TYPE_ADMIN
    ).first
    return !organization_user.blank?
  end

  def is_organization_member?(organization_id)
    return true if self.is_super?

    organization_user = OrganizationUser.where(
      user_id: self.id,
      organization_id: organization_id
    ).first
    return !organization_user.blank?
  end

  def context
    if self.is_organization_admin? self.organization
      return self.organization
    end 

    return self
  end

  def is_org_deal_admin?(deal_id)
    return true if self.is_super?

    deal = Deal.find_by_id(deal_id)
    return (deal and (deal.admin_user_id == self.id or deal.organization.creator.id == self.id))
  end

  def is_deal_admin? deal
    return true if self.is_super?
    return true if self.is_organization_admin? deal.organization
    return true if deal.creator == self

    return false
  end

  def is_deal_collaborator?(deal_id)
    return true if self.is_super? or self.is_org_deal_admin?(deal_id)

    deal = Deal.find_by_id(deal_id)

    deal_collaborator = DealCollaborator.where(
      user_id: id,
      deal_id: deal_id
    ).first
    return !deal_collaborator.blank?
  end

  def is_document_owner?(document_id)
    return true if self.is_super?
    document = Document.find_by_id(document_id)

    return (document and document.created_by == self.id)
  end

  def is_comment_owner?(comment_id)
    return true if self.is_super?
    comment = Comment.find_by_id(comment_id)

    return (comment and comment.user_id == self.id)
  end

  def is_notification_reciever?(notification_id)
    return true if self.is_super?
    notification = Notification.find_by_id(notification_id)

    return (notification and notification.user_id == self.id)
  end

  def is_super?
    self.role == "Super"
  end

  # We implement this because it's required by DealOwner
  def email_domain
    self.organization.email_domain
  end

  def to_hash(add_organization = true)
    data = {
      email: self.email,
      user_id: self.id,
      first_name: self.first_name,
      last_name: self.last_name,
      phone: self.phone,
      address: self.address,
      company: self.company,
      activated: self.activated,
      role: self.role
    }

    if add_organization and self.organization
      data[:organization] = [
        {
          id: self.organization.id,
          name: self.organization.name
        }
      ]
    end

    return data
  end

  def initials
    first_name[0] + last_name[0]
  end
end
