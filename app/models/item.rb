class Item < ActiveRecord::Base
  validates :code, presence: true
end
