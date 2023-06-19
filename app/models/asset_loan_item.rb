class AssetLoanItem < ActiveRecord::Base
  belongs_to :asset_loan, class_name: "AssetLoan", foreign_key: :asset_loan_id
  belongs_to :item, class_name: "Item", foreign_key: :item_id
  belongs_to :admin, class_name: "User", foreign_key: :admin_id


end
