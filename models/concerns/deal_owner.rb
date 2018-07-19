module DealOwner
  extend ActiveSupport::Concern

  included do
    has_many :deals, dependent: :delete_all
  end

  def deal_stats
    active_deals = deals.where(status: Deal::ACTIVE_STATUSES)
    archived_deals = deals.where(status: Deal::ARCHIVED_STATUSES)
    team_members = deals.map(&:users).flatten.uniq
    outside_collaborators = team_members.select{|team_member| team_member.email.include? email_domain}

    return {
      active_deals: active_deals.count,
      archived_deals: archived_deals.count,
      team_members: team_members.count, 
      outside_collaborators: outside_collaborators.count
    }
  end

  def recently_updated_files
    ids = deals.map(&:id)

    folders = Folder.where(deal_id: ids).order('updated_at').last(5)
    documents = Document.where(deal_id: ids).order('updated_at').last(5)

    (documents + folders).sort_by{|e| e.updated_at}.last(5).reverse
  end

  def events
    Event.where(deal_id: deals.map(&:id))
  end
end