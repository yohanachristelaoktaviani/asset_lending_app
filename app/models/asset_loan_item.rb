class AssetLoanItem < ActiveRecord::Base
  belongs_to :asset_loan, class_name: "AssetLoan", foreign_key: :asset_loan_id, optional: true
  belongs_to :item, class_name: "Item", foreign_key: :item_id
  # belongs_to :item_condition, class_name: "Item", foreign_key: :item_id
  belongs_to :admin, class_name: "User", foreign_key: :admin_id, optional: true


  def user_name
    asset_loan.user&.name
  end

  def self.generate_csv(loan_items)
    attributes = %w[loan_id item_name item_code user_name loan_date return_estimation_date item_condition necessary admin_name loan_status evidence]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      loan_items.each do |loan_item|
        csv << [
          loan_item.asset_loan.code,
          loan_item.item.name,
          loan_item.item.code,
          loan_item.asset_loan.user.name,
          loan_item.asset_loan.loan_item_datetime,
          loan_item.asset_loan.return_estimation_datetime,
          loan_item.item.condition,
          loan_item.asset_loan.necessary,
          loan_item.admin.name,
          loan_item.loan_status,
          loan_item.evidence
        ]
      end
    end
  end

end
