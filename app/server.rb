require 'rubygems'
require 'sinatra/base'
require 'data_mapper'
require 'rack-flash'
require './lib/link.rb'
require './lib/tag.rb'
require './lib/user.rb'
require_relative './helpers/application.rb'
require_relative './data_mapper_setup.rb'

use Rack::MethodOverride

class BookmarkManager < Sinatra::Base

  enable :sessions
  set :session_secret, 'super secret'
  use Rack::Flash

  set :views, Proc.new{File.join(root, 'views')}
  
  get '/' do
    @links = Link.all
    erb :index
  end

  post '/links' do
    url = params["url"]
    title = params["title"]
    tags = params["tags"].split(" ").map{|tag| Tag.first_or_create(:text => tag)}
    Link.create(:url => url, :title => title, :tags => tags)
    redirect to('/')
  end

  get '/tags/:text' do
    tag = Tag.first(:text => params[:text])
    @links = tag ? tag.links : []
    erb :index
  end

  get '/users/new' do
    @user = User.new
    erb :"users/new"
  end

  post '/users' do
    @user = User.new(:email => params[:email],
                    :password => params[:password],
                    :password_confirmation => params[:password_confirmation])
    if @user.save
      session[:user_id] = @user.id
      redirect to('/')
    else
      flash.now[:errors] = @user.errors.full_messages
      erb :"users/new"
    end
  end

  post '/sessions' do
    email, password = params[:email], params[:password]
    user = User.authenticate(email, password)
    if user
      session[:user_id] = user.id
      redirect to('/')
    else
      flash[:errors] = ["The email or password is incorrect"]
      erb :"sessions/new"
    end
  end

  get '/sessions/new' do
    erb :"sessions/new"
  end

  # start the server if ruby file executed directly
  run! if app_file == $0

  def self.authenticate(email, password)
    user = first(:email => email)
    if user && BCrypt::Password.new(user.password_digest) == password
      user
    else
      nil
    end
  end

end