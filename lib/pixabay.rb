require 'sqlite3'
require 'httparty'
require 'json'
require 'down'

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
      ids_urls = image_ids_urls(response)
      filenames = download_images(ids_urls.map(&:last))
      ids_filenames = ids_urls.map(&:first).zip filenames
      cache_images(ids_filenames)

      insert_filenames(response, filenames)
      response
    end

    def uncached_query(**terms)
        unless terms.key?('key') || terms.key?(:key)
            terms[:key] = @key
        end
        query_string = '?' + terms.map { |k, v| "#{k}=#{v}" }.join('&')

        response = HTTParty.get('https://pixabay.com/api/' + query_string)
        if response.code < 200 || response.code >= 300
            raise "Query response status: #{response.code}"
        end

        JSON.parse(response.body)
    end

    private

    def insert_filenames(response, filenames)
      response['hits'].zip(filenames).each do |info, filename|
        info['filename'] = filename
      end
      nil
    end

    def image_ids_urls(response)
      response['hits'].map { |info| [info['id'], info['webformatURL']] }
    end

    def download_images(urls)
      urls.map do |url|
        tempfile = Down.download(url)
        FileUtils.mv(tempfile.path, "#{@cache_dir}#{tempfile.original_filename}", force: true)

        tempfile.original_filename
      end
    end

    def cache_images(ids_filenames)
      sql_values = ids_filenames
                     .map { |(id, filename)| "(#{id}, '#{filename}')" }
                     .join(', ')
      sql_query = "INSERT INTO images (image_id, filename) VALUES " + sql_values
      @cache_db.execute(sql_query)
    end
end
