require 'rubygems'
require 'sinatra'
require 'sinatra/formkeeper'
require 'haml'
require 'aws-sdk'
require 'securerandom'

class Registration < Sinatra::Base
  register Sinatra::FormKeeper
  set :public_folder, 'public'
  @@s3 = AWS::S3.new(
    :access_key_id => ENV['REG_S3_ID'],
    :secret_access_key => ENV['REG_S3_SECRET']
    )
  get '/form' do 
    haml :index
  end
  post '/form' do
    form do
      # filters :strip
      field :name, present: true
      field :email,present: true, email: true
      field :school_email, present: true, email: true
      field :release, present: true
      field :resume, present: true
    end
    if form.failed?
      out = haml :index
      fill_in_form(out)
    else
      @@s3.buckets['mchacksreg/resumes'].objects[form[:name].split(" ").join.downcase+SecureRandom.hex(5)].write(form[:resume][:tempfile])
      @@s3.buckets['mchacksreg/press'].objects[form[:name].split(" ").join.downcase+SecureRandom.hex(5)].write(form[:release][:tempfile])
      haml :thanks
    end
  end
    get '/thanks' do
    haml :thanks
  end
end
run Registration
