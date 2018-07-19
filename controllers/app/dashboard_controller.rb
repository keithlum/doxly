class App::DashboardController < App::ApplicationController
  before_action :authenticate_user!
  
  def index
    @deal_stats = current_user.context.deal_stats
    @recently_updated_files = current_user.context.recently_updated_files
    @deals_behind_schedule = current_user.context.deals.behind_schedule
    @deals_nearing_completion = current_user.context.deals.nearing_completion

    @events = current_user.context.events
  end
end