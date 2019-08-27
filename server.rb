require 'sinatra'

class Server < Sinatra::Base
    get '/' do
        erb :index
        
    end
    get '/s' do
        erb :search
    end
    
end