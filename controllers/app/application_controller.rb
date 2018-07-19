class App::ApplicationController < ApplicationController
  include ReactOnRails::Controller

  before_filter :get_starred_deals, if: "current_user"

  def get_starred_deals
    @starred_deals = StarredDeal.includes(:deal)
                                .where(user_id: current_user.id)
                                .map {|sd| {id: sd.deal_id, title: sd.deal.title, url: app_deal_path(sd.deal)}}
  end

  def add_to_redux_store key, value
    @redux_store_data ||= {}
    @redux_store_data[key] = value;
  end

  def initialize_redux_store
    @redux_store_data ||= {}

    # Data that we need for every page goes here
    # Add starred deals
    if current_user
      add_to_redux_store :starred_deals, @starred_deals
    end
    redux_store('doxlyStore', props: @redux_store_data)
  end

  # We put this here because there is no callback
  # that lets us sit in between the action and the
  # render. We need this to be here so that we can
  # selectively register more data to go into the
  # redux store with add_to_redux_store
  def render *args
    initialize_redux_store
    super
  end
end