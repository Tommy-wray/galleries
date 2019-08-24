require 'rspec'
require_relative '../lib/gallery.rb'


describe 'Creating a Gallery' do
  describe 'GIVEN the Gallery class and an API params constant for pixabay.com' do
    describe 'WHEN Gallery#new is called with no arguments' do
      it "THEN an object is created which has attributes Pixabay's API exposes" do
        gallery = Gallery.new
        expect(gallery).to respond_to(*$API_PARAMS.map(&:to_sym))
      end
    end
  end
end

describe 'Configuring a Gallery' do
  before :each do
    @gallery = Gallery.new
  end

  describe 'GIVEN some search terms' do
    describe 'WHEN #add_search_terms is called with a single term' do
      it 'THEN it sets #q to that term' do
        @gallery.add_search_terms('foo')
        expect(@gallery.q).to eq('foo')
      end
    end

    describe 'WHEN #add_search_terms is called with a single term multiple times' do
      it 'THEN it sets #q to those terms joined with "+"' do
        @gallery.add_search_terms('foo')
        @gallery.add_search_terms('bar')
        @gallery.add_search_terms('baz')
        expect(@gallery.q).to eq('foo+bar+baz')
      end
    end

    describe 'WHEN #add_search_terms is called with multiple terms' do
      it 'THEN it sets #q to those terms joined with "+"' do
        @gallery.add_search_terms('foo', 'bar', 'baz')
        expect(@gallery.q).to eq('foo+bar+baz')
      end
    end
  end
end
