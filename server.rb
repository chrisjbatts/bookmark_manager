require 'data_mapper'

env = ENV["RACK_ENV"]  || "development"

DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")

require_relative './lib/link.rb'

DataMapper.finalize
DataMapper.auto_upgrade!

require 'sinatra/base'

class BookmarkManager < Sinatra::Base
  get '/' do
    'Hello BookmarkManager!'
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
