require 'sinatra/base'
require 'data_mapper'

env = ENV["RACK_ENV"]  || "development"

DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")

require './lib/link.rb'
require './lib/tag.rb'
require './lib/user.rb'

DataMapper.finalize
DataMapper.auto_upgrade!

  # helpers do

    def current_user
      @current_user ||= User.get(session[:user_id]) if session[:user_id]
    end

  # end

class BookmarkManager < Sinatra::Base

  set :views, Proc.new{File.join(root,'views')}
  
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
    erb :"users/new"
  end

  post '/users' do
    user = User.new(:email => params[:email],
                :password => params[:password])
    user.save
    session[:user_id] = user.id
    redirect to('/')
  end

  enable :sessions
  set :session_secret, 'super secret'



  # start the server if ruby file executed directly
  run! if app_file == $0

end
