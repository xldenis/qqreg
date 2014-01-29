class Registration  < Sinatra::Base
  register Sinatra::FormKeeper

  post '/' do 
    form do
      filters :strip
      field :name, present: true
      field :email,present: true
      field :school_email, present: true
      field :waiver, present: true
      field :resume, present: true
    end
  end
end
