class AssetLoan < ActiveRecord::Base
  has_many :asset_loan_items, dependent: :destroy
  has_many :asset_returns
  belongs_to :user, class_name: "User", foreign_key: :user_id

  accepts_nested_attributes_for :asset_loan_items, allow_destroy: true
  after_initialize :generate_code, if: :new_record?
  validate :check_dates
  validate :validate_nested_attributes

  private

  def generate_code
    recent_id = AssetLoan.maximum(:id).to_i || 0

    code = "LO" + (recent_id + 1).to_s.rjust(5,'0')

    self.code = code
  end

  def reset_code
    self.code = ""
  end

  def check_dates
    if self.return_estimation_datetime.present? && self.loan_item_datetime.present? && self.return_estimation_datetime < self.loan_item_datetime
      errors.add(:base, "Estimation date should be greater than loan date")
    elsif self.return_estimation_datetime.present? && self.loan_item_datetime.present? && self.return_estimation_datetime == self.loan_item_datetime
      errors.add(:base, "Estimation date can't be the same as loan date")
    end
  end

  def validate_nested_attributes
    if asset_loan_items.reject(&:marked_for_destruction?).blank?
      errors.add(:base, 'Items must be filled')
    end
  end
end
