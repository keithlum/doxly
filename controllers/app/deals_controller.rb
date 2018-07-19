class App::DealsController < App::ApplicationController
  before_filter :authenticate_user!

  def index
    @deals = format_deals_for_display(current_user.context.deals)
  end

  def show
    @deal = Deal.find(params[:id])
  end

  private

  # This method will add the collaborators attribute, the starred attribute
  # and will group the deals together
  def format_deals_for_display deals
    deals = deals.map {|deal| deal.attributes.merge({collaborators: deal.users, 
                                                     starred: deal.starred_deals.where(user_id: current_user.id).present? })}

    grouped = deals.group_by {|deal| DateTime.parse(deal["projected_close_date"].to_s).strftime("%B %Y")}

    grouped.keys.map {|key| {heading: key, deals: grouped[key]}}

  end
end