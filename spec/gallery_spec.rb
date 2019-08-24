require 'rspec'
require_relative '../lib/gallery.rb'


describe 'Creating a Gallery' do
  describe 'GIVEN the Gallery class, some criteria, and a Pixabay object' do
    describe 'WHEN Gallery#new is called with no arguments' do
      it "THEN an object is created which has attributes Pixabay's API exposes" do
        gallery = Gallery.new
        expect(gallery).to respond_to(*$API_PARAMS.map(&:to_sym))
      end
    end
  end
end
