class AssetReturn < ActiveRecord::Base

  has_many :asset_return_items
  belongs_to :user, class_name: "User", foreign_key: :user_id
  # belongs_to :asset_loan
  belongs_to :asset_loan, class_name: "AssetLoan", foreign_key: :asset_loan_id
  has_many :items, through: :asset_return_items
  accepts_nested_attributes_for :asset_return_items
  # belongs_to :item
  attribute :actual_return_datetime, :datetime, default: -> { Time.current }

  # def formatted_actual_return_datetime
  #   actual_return_datetime.strftime('%Y-%m-%d %H:%M:%S %z')
  # end

end
