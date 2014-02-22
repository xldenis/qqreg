require 'data_mapper'
require 'dm-mysql-adapter'

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

