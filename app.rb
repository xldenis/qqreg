require 'sinatra'
require 'sinatra/formkeeper'
require 'haml'
require 'aws-sdk'
require 'securerandom'
require 'data_mapper'
require 'dm-mysql-adapter'
require 'sinatra/assetpack'

DataMapper.setup(:default,ENV['REG_DB_URL'])

class User 
  include DataMapper::Resource
  property :id, Serial
  property :name, String, required: true, 
  messages: {
    presence: "We need your name."
  }
  property :email, String, required: true, unique: true,
  messages: {
    presence: "We need your Eventbrite email.",
    is_unique: "We already have that eventbrite email."
  }
  property :school_email, String,required: true, unique: true,
  messages: {
    presence: "We need your school email.",
    is_unique: "We already have that school email."
  }
  property :file_salt, String, required: true
end

DataMapper.finalize.auto_upgrade!

class Registration < Sinatra::Base
  register Sinatra::FormKeeper
  register Sinatra::AssetPack

  assets {
    serve '/css', from: 'public/css'
    
    css :app, ['/css/*.css']
  }
  set :public_folder, 'public'

  @@s3 = AWS::S3.new( :access_key_id => ENV['REG_S3_ID'], :secret_access_key => ENV['REG_S3_SECRET'])

  get '/' do 
    redirect to('/form')
  end
  get '/form' do 
    haml :index, locals: {errors: nil}
  end
  post '/form' do
    form do
      # filters :strip
      field :name, present: true
      field :email,present: true, email: true
      field :school_email, present: true, email: true
      # field :release, present: true
      field :resume, present: true
    end
    if form.failed?
      out = haml :index, locals: {errors: nil}
      fill_in_form(out)
    else
      user = User.new(name: form[:name],email: form[:email],school_email: form[:school_email],file_salt: SecureRandom.hex(5))
      if user.save
        @@s3.buckets['mchacksreg/resumes'].objects[form[:name].split(" ").join.downcase+user.file_salt].write(form[:resume][:tempfile])
        # @@s3.buckets['mchacksreg/press'].objects[form[:name].split(" ").join.downcase+user.file_salt].write(form[:release][:tempfile])
        haml :thanks
      else
        errors = user.errors
        out = haml :index, locals: {errors: errors}
        fill_in_form(out)
      end 
    end
  end
  get '/thanks' do
    haml :thanks
  end
  get '/schedule' do 
    times =  %w( 8:00 10:00 11:30 4:00 8:00 12:00 4:00 8:00 1:00 3:30 4:30)
    descriptions = ["General Registration & Breakfast","Opening Ceremonies","Hacking Starts & Lunch","Snack Brought to you by Twilio","Dinner","HypeJar's Midnight Cookies","HuffPostCode's Hack-tastic Snack","Breakfast","Hacking Stops, Lunch & Judging", "Final 8","Closing Ceremonies"]
    haml :schedule, locals: {table: (times.zip descriptions)}
  end
end