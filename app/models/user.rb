class User < ActiveRecord::Base
  has_many :channels, :foreign_key => 'author_id'
  validates_uniqueness_of :screen_name
end
