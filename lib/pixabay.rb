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

      cached = get_cached_images(response['hits'].map { |e| e['id'] }).to_h
      to_be_cached = []

      response['hits'].each do |hit|
        id, url = hit['id'], hit['webformatURL']

        if cached.key? id
          hit['filename'] = cached[id]
        else
          filename = download_image(url)
          to_be_cached.push([id, filename])
          hit['filename'] = filename
        end
      end

      cache_images(to_be_cached) unless to_be_cached.empty?

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

    def get_cached_images(ids)
      query_list = "(" + ids.join(', ') + ")"
      @cache_db.execute("SELECT image_id, filename FROM images WHERE image_id IN #{query_list};")
    end

    def download_image(url)
      tempfile = Down.download(url)
      FileUtils.mv(tempfile.path, "#{@cache_dir}#{tempfile.original_filename}", force: true)

      tempfile.original_filename
    end

    def cache_images(ids_filenames)
      sql_values = ids_filenames
                     .map { |(id, filename)| "(#{id}, '#{filename}')" }
                     .join(', ')
      sql_query = "INSERT INTO images (image_id, filename) VALUES " + sql_values
      @cache_db.execute(sql_query)
    end
end
