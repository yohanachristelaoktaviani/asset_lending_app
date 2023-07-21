class Item < ActiveRecord::Base
  validates :code, presence: true
  has_one_attached :image
  has_many :asset_loan_items
  has_many :asset_return_items
  has_many :asset_returns, through: :asset_return_items


  validates :image, blob: { content_type: ['image/png', 'image/jpg', 'image/jpeg'], size_range: 1..5.megabytes }
  validates :code, presence: true, uniqueness: {scope: :code}

  def self.to_csv(items)
    attributes = %w[code name merk vendor_name condition status description]
    CSV.generate(headers: true) do |csv|
      csv << attributes
      items.each do |item|
        csv << attributes.map{|attr| item.send(attr) }
      end
    end
  end

end
