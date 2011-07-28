class OauthConsumersController < ApplicationController
  include Oauth::Controllers::ConsumerController

  before_filter :authenticate_user!, :only => [:index]

  def index
    @consumer_tokens = ConsumerToken.all :conditions=>{:user_id=>current_user.id}
    @services        = OAUTH_CREDENTIALS.keys - @consumer_tokens.collect{|c| c.class.service_name}
  end

  def callback
    super
  end

  # example of 3-legged API call
  def resources
    response = @token.client.get("/api/v1/photos.json")
    response = @token.client.post("/api/v1/blog_posts.json", "title" => "A New Biology Book", "body" => "Michael Cain (Units 4 and 5) is an ecologist and evolutionary biologist who is now writing full time.", "tags" => "biology")
    render :json => response.body
  end

  # Example of two_legged API call
  def simple_oauth
    consumer = OAuth::Consumer.new(OAUTH_CREDENTIALS[:remix][:key], OAUTH_CREDENTIALS[:remix][:secret],
                               :site => OAUTH_CREDENTIALS[:remix][:options][:site])
    access_token = OAuth::AccessToken.new consumer

    response =  access_token.get("/api/v1/photos.json")
    render :json => response.body
  end

  protected

  # Change this to decide where you want to redirect user to after callback is finished.
  # params[:id] holds the service name so you could use this to redirect to various parts
  # of your application depending on what service you're connecting to.
  def go_back
    redirect_to root_url
  end

  # The plugin requires logged_in? to return true or false if the user is logged in. Uncomment and
  # call your auth frameworks equivalent below if different. eg. for devise:
  #
   def logged_in?
     user_signed_in?
   end

  # The plugin requires current_user to return the current logged in user. Uncomment and
  # call your auth frameworks equivalent below if different.
  # def current_user
  #   current_person
  # end

  # The plugin requires a way to log a user in. Call your auth frameworks equivalent below
  # if different. eg. for devise:
  #
  def current_user=(user)
     sign_in(user)
  end

  # Override this to deny the user or redirect to a login screen depending on your framework and app
  # if different. eg. for devise:
  #
  def deny_access!
     redirect_to new_user_session_url
  end
end

