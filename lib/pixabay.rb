require 'sqlite3'

class Pixabay
    attr_accessor :key
    attr_reader :cache_db
    def initialize(key, cache_db)
        @key = key
        @cache_db = cache_db
    end

    def cache_db=(db)
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

        @cache_db = db
    end
end