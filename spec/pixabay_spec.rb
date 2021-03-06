require 'rspec'
require 'sqlite3'
require 'fileutils'
require 'pry'
require_relative '../lib/pixabay.rb'

$CACHE_DIR = __dir__ + '/../test_images/'

describe 'Creating an API object' do
    describe 'GIVEN an sql database object and an API key' do
        before do
            FileUtils.rm('test.db', force: true)
            @db = SQLite3::Database.new('test.db')
        end

        describe 'WHEN Pixabay.new is called with the db and API' do
            it 'THEN the db is populated with an images table' do
                pixabay = Pixabay.new('', @db, $CACHE_DIR)
                images_table_info  = @db.execute("PRAGMA table_info(images)").map { |row| row[1] }

                %w[image_id filename].each do |column|
                    expect(images_table_info).to include(column)
                end
            end
        end
    end
end

describe 'Querying the API object' do
    before :all do
        FileUtils.rm('test.db', force: true)
        @db  = SQLite3::Database.new('test.db')
        @api = Pixabay.new(ENV['PIXABAY_KEY'], @db, $CACHE_DIR)
    end

    describe 'GIVEN a search term' do
        describe 'WHEN #uncached_query is called with a symbol key argument' do
            it 'THEN it returns a hash' do
                response = @api.uncached_query(q: 'flower+alien')
                expect(response.respond_to? :key?).to be_truthy
            end
        end

        describe 'WHEN #uncached_query is called with a string key argument' do
          it 'THEN it returns a hash' do
            response = @api.uncached_query('q': 'flower+alien')
            expect(response.respond_to? :key?).to be_truthy
          end
        end

        describe 'WHEN #query is called with a search term key argument' do
            before do
              @terms = {q: 'flower+alien'}
              @response = @api.query(**@terms)
              @cached = @db.execute("SELECT image_id, filename FROM images")
            end

            it 'THEN it downloads the images and caches them in the database' do
              image_ids = @cached.map(&:first)
              filenames = @cached.map(&:last)

              expect(image_ids.empty?).to be(false)
              expect(filenames.empty?).to be(false)

              expect(image_ids).to all( be_a(Integer) )
              expect(filenames).to all( match(/.+\..+/) )

              dir_contents = Dir[$CACHE_DIR + '*.*'].map { |e| e.split('/').last }

              filenames.each do |filename|
                expect(dir_contents).to include(filename)
              end
            end
        end

        describe 'WHEN #query is called again with the same arguments' do
          before do
            @terms = {q: 'flower+alien'}
            @cached = @db.execute("SELECT image_id, filename FROM images")
          end

          it 'THEN it does not redownload the images' do
            expect(@cached.empty?).to be(false)
            FileUtils.rm_rf(Dir[$CACHE_DIR + '*'])
            @api.query(**@terms)
            expect(Dir[$CACHE_DIR + '*']).to eq([])
          end
        end
    end
end
