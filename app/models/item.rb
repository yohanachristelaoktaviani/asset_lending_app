class Item < ActiveRecord::Base
  validates :code, presence: true
  has_one_attached :image
  has_many :asset_loan_items

  validates :image, presence: true, blob: { content_type: ['image/png', 'image/jpg', 'image/jpeg'], size_range: 1..5.megabytes }
  validates :code, presence: true, uniqueness: {scope: :code}

end
