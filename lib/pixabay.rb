require 'sqlite3'
require 'httparty'
require 'json'

class Pixabay
    attr_accessor :key
    attr_reader :cache_db
    def initialize(key, db)
        @key = key
        self.class.setup_tables(db)
        @cache_db = db
    end

    def self.setup_tables(db)
        db.execute_batch <<-SQL
        CREATE TABLE IF NOT EXISTS images (
            image_id INTEGER PRIMARY KEY,
            filename TEXT
        );

        CREATE TABLE IF NOT EXISTS queries (
            id INTEGER PRIMARY KEY,
            query TEXT,
            response TEXT
        );
        SQL
    end

    def cache_db=(db)
        self.class.setup_tables(db)
        @cache_db = db
    end

    def query(**terms)
        response = uncached_query(**terms)

        @cache_db.execute("""
        INSERT INTO queries (query, response)
        VALUES (?, ?);
        """, terms.to_json, response.to_json)

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
end
