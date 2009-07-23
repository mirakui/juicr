class Channel < ActiveRecord::Base
  SEARCH_ENGINE_OFFICIAL = 0
  SEARCH_ENGINE_YATS = 1
  PERM_SHOW_PRIVATE = 0
  PERM_SHOW_PROTECTED = 1
  PERM_SHOW_PUBLIC = 2
  PERM_EDIT_PRIVATE = 0
  PERM_EDIT_PROTECTED = 1
  PERM_EDIT_PUBLIC = 2

  belongs_to :author, :class_name => 'User'

  validates_uniqueness_of :alias
  validates_length_of :alias, :within => (2..30)
  validates_format_of :alias, :with => /^[a-zA-Z0-9_]+$/

  before_create :build_all
  before_update :build_all

  #validates_exclusion_of :search_engine, :in => [
  #  SEARCH_ENGINE_OFFICIAL,
  #  SEARCH_ENGINE_YATS
  #]

  def build_all
    build_extract_users
    build_query
  end

  def build_extract_users
    logger.debug 'extract_users: ' + extract_users.inspect
    self.extract_users = extract_users.split(/\s+/).join("\001")
    logger.debug 'build_extract_users: ' + extract_users.inspect
    logger.debug 'search_engine: ' + search_engine.inspect
  end

  def search_engine_uri_base
    case search_engine
    when SEARCH_ENGINE_OFFICIAL
      'http://search.twitter.com/search.json?q='
    when SEARCH_ENGINE_YATS
      'http://pcod.no-ip.org/yats/search?query='
    end
  end

  def build_query
    str = ''
    case search_engine
    when SEARCH_ENGINE_OFFICIAL
      logger.debug 'SEARCH_ENGINE_OFFICIAL' + extract_users.split("\001").inspect
      str << extract_users.split("\001").map{|t|"from:#{t}"}.join('+OR+')
    when SEARCH_ENGINE_YATS
      logger.debug 'SEARCH_ENGINE_YATS'
      str << 'user:' + extract_users.split("\001").join(',')
    end
    str << '+' + URI.encode(keywords) if keywords && keywords.length > 0
    self.query = str
  end

end
