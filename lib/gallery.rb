$API_PARAMS = %w[q lang id image_type orientation category min_width min_height colors editors_choice safesearch order page per_page callback pretty]

$API_CATEGORIES = %w[fashion nature backgrounds science education people feelings religion health places animals industry food computer sports transportation travel buildings business music]

$API_COLORS = %w[grayscale transparent red orange yellow green turquoise blue lilac pink white gray black brown]

class Gallery
  custom_getters_setters = %w[category order]
  attr_accessor(*$API_PARAMS
                   .reject { |param| custom_getters_setters.include? param }
                   .map(&:to_sym))

  attr_accessor :name

  def initialize(name)
    @name = name
    $API_PARAMS.each { |param| instance_variable_set('@'+param, '')}
  end

  def generate_query
    $API_PARAMS
      .map { |param| [param.to_sym, instance_variable_get("@#{param}")] }
      .reject { |(_, value)| value.empty? }
      .to_h
  end

  def category
    @category
  end

  def category=(cat)
    if $API_CATEGORIES.include? cat
      @category = cat
    else
      raise "Category '#{cat}' is not recognised by pixabay"
    end
  end

  def order
    @order
  end

  def order=(value)
    if value == 'popular' || value == 'latest'
      @order = value
    else
      raise "order set to '#{value}' but pixabay only accepts 'popular' or 'latest'"
    end
  end

  def add_search_terms(*terms)
    terms = [@q] + terms unless @q.empty?
    @q = terms.join('+')
  end

  def reset_search_terms
    @q = ''
  end

  def add_colors(*colors)
    wrong_colors = colors.reject { |color| $API_COLORS.include? color }
    if wrong_colors.empty?
      colors = [@colors] + colors unless @colors.empty?
      @colors = colors.join(',')
    else
      raise "Colors #{wrong_colors} are not recognised by pixabay"
    end
  end
end
