require 'rspec'
require 'sqlite3'
require 'pry'
require_relative '../lib/pixabay.rb'

describe 'Creating an API object' do
    describe 'GIVEN an sql database object and an API key' do
        before do
            @db = SQLite3::Database.new('test.db')
        end

        describe 'WHEN Pixabay.new is called with the db and API' do
            it 'THEN the db is populated with images and queries tables' do
                pixabay = Pixabay.new('', @db)
                images_table_info  = @db.execute("PRAGMA table_info(images)").map { |row| row[1] }
                queries_table_info = @db.execute("PRAGMA table_info(queries)").map { |row| row[1] }

                %w[image_id filename].each do |column|
                    expect(images_table_info).to include(column)
                end

                %w[query response].each do |column|
                    expect(queries_table_info).to include(column)
                end
            end
        end
    end
end