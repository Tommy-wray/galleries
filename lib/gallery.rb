$API_PARAMS = %w[q lang id image_type orientation category min_width min_height colors editors_choice safesearch order page per_page callback pretty]

class Gallery
  attr_reader(*$API_PARAMS.map(&:to_sym))
end
