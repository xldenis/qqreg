require 'rubygems'
require 'sinatra'
require 'sinatra/formkeeper'
require 'haml'

class Registration < Sinatra::Base
  # register Sinatra::FormKeeper

  get '/' do 
    # form do
    #   filters :strip
    #   field :name, present: true
    #   field :email,present: true, email: true
    #   field :school_email, present: true, email: true
    #   field :waiver, present: true
    #   field :resume, present: true
    # end
    # haml :index
    "test"
  end
  post '/submit' do
  end
end
run Registration