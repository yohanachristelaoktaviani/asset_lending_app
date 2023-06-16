class AssetLoan < ActiveRecord::Base
  has_many :asset_loan_items
  belongs_to :user, class_name: "User", foreign_key: :user_id
  accepts_nested_attributes_for :asset_loan_items, allow_destroy: true
end
