class Item < ActiveRecord::Base
  validates :code, presence: true
  has_many_attached :image
  has_many :asset_loan_items
  has_many :asset_return_items
  has_many :asset_returns, through: :asset_return_items
  belongs_to :admin, class_name: "User", foreign_key: :admin_id, optional: true

  has_paper_trail
  # has_paper_trail on: [:create, :update], # Only track changes on create and update actions
  #                meta: { user_id: :whodunnit }, # Include user_id in metadata
  #                versions: { class_name: 'ItemVersion' } # Use a custom class for versions

  validates :image, blob: { content_type: ['image/png', 'image/jpg', 'image/jpeg'], size_range: 1..5.megabytes }
  validates :code, presence: true, uniqueness: {scope: :code}

  def self.to_csv(items)
    attributes = %w[code name item_type vendor_name condition status description location serial_number purchase_date]
    CSV.generate(headers: true, quote_char: '"', force_quotes: true) do |csv|
      csv << attributes
      items.each do |item|
        csv << attributes.map{|attr| "#{item.send(attr)}" }
      end
    end
  end

end
