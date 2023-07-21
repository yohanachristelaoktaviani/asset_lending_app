class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :asset_returns
  has_many :asset_return_items
  has_many :asset_loans
  belongs_to :department, class_name: "Department", foreign_key: :department_id
  belongs_to :position, class_name: "Position", foreign_key: :position_id

  validates :code, presence: true
  validates :name, format: { with: /\A[a-zA-Z\s]+\z/, message: "only allows letters" }

  # validates  :code, exclusion: {in:->(record) {[record.code]}, message: "Employee ID must be unique" }

  validates :code, presence: true, uniqueness: {scope: :code}

  def self.to_csv(users)
    attributes = %w[code name department_name position_name role email]
    CSV.generate(headers: true) do |csv|
      csv << attributes
      users.includes(:department, :position).each do |user|
        csv << attributes.map { |attr| user.send(attr) }
      end
    end
  end

  def department_name
    department&.code_name
  end

  def position_name
    position&.code_name
  end
end
