module ItemVersionDecorator
  def whodunnit_name
    if whodunnit.present? && whodunnit.to_i.to_s == whodunnit
      admin = User.find_by(id: whodunnit, admin: true)
      admin.name if admin
    else
      whodunnit
    end
  end
end