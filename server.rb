require 'sinatra'
require_relative './lib/gallery.rb'
require_relative './lib/pixabay.rb'

class Server < Sinatra::Base
    def initialize 
        @flower_gallery = Gallery.new("Flowers")
        @citys_gallery = Gallery.new("Citys")
        @beach_gallery = Gallery.new("Beach")
        @ocean_gallery = Gallery.new("Ocean")
        @people_gallery = Gallery.new("People")
        @alien_gallery = Gallery.new("Alien")
        @fractal_gallery = Gallery.new("Fractal")
        @maths_gallery = Gallery.new("Maths")
        super
    end 
    
    get '/' do
        erb :index
        
    end
    get '/s' do
        erb :search
    end
    
end