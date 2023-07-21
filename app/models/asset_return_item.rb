class AssetReturnItem < ActiveRecord::Base
  belongs_to :asset_return, class_name: "AssetReturn", foreign_key: :asset_return_id, optional: true
  belongs_to :item, class_name: "Item", foreign_key: :item_id
  # belongs_to :item_condition, class_name: "Item", foreign_key: :item_id
  belongs_to :admin, class_name: "User", foreign_key: :admin_id, optional: true

  # validates :asset_return, presence: true
  # validates :admin, presence: true

  def item_name
    self.item.name
  end

  def return_status?
    return_status.present?
  end

  def user_name
    asset_loan.user&.name
  end

  def self.generate_csv(return_items)
    attributes = %w[return_id item_name item_code user_name actual_return_date actual_item_condition return_status admin_name status]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      return_items.each do |return_item|
        csv << [
          return_item.asset_return.code,
          return_item.item.name,
          return_item.item.code,
          return_item.asset_return.user.name,
          return_item.asset_return.actual_return_datetime,
          return_item.actual_item_condition,
          return_item.asset_return.return_status,
          return_item.admin&.name,
          return_item.status,
        ]
      end
    end
  end

end
