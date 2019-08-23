require 'sqlite3'
require 'httparty'
require 'json'

class Pixabay
    attr_accessor :key
    attr_reader :cache_db
    def initialize(key, db, cache_directory)
        @key = key
        self.class.setup_tables(db)
        @cache_db = db
        @cache_dir = cache_directory
    end

    def self.setup_tables(db)
        db.execute <<-SQL
        CREATE TABLE IF NOT EXISTS images (
            image_id INTEGER PRIMARY KEY,
            filename TEXT
        );
        SQL
    end

    def cache_db=(db)
        self.class.setup_tables(db)
        @cache_db = db
    end

    def query(**terms)
      response = uncached_query(**terms)
      insert_filenames response
      cache_images response

      response
    end

    def uncached_query(**terms)
        unless terms.key?('key') || terms.key?(:key)
            terms[:key] = @key
        end
        query_string = '?' + terms.map { |k, v| "#{k}=#{v}" }.join('&')

        response = HTTParty.get('https://pixabay.com/api/' + query_string)
        if response.code < 200 || response.code >= 300
            raise 'Query response status: #{response.code}'
        end

        JSON.parse(response.body)
    end

    private

    def insert_filenames(response)
      response['hits'].each do |info|
        info['filename'] = info['webformatURL'].split(',').last
      end
      nil
    end

    def image_ids_urls_filenames(response)
      response['hits'].map { |info| [info['id'], info['webformatURL'], info['filename']] }
    end

    def download_images(ids_urls)
    end

    def cache_images(response)
      ids_urls_filenames = image_ids_urls_filenames(response)
      download_images(ids_urls_filenames[0..1])

      sql_values = ids_urls_filenames
                     .map { |(id, _, filename)| "(#{id}, '#{filename}')" }
                     .join(', ')
      sql_query = "INSERT INTO images (image_id, filename) VALUES " + sql_values
      @cache_db.execute(sql_query)
    end
end
