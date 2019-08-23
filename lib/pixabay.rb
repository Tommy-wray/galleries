require 'sqlite3'

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
end