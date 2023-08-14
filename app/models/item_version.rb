class ItemVersion < PaperTrail::Version

  # Custom method to display changeset in a human-readable format
  def display_changeset
    return "" unless changeset

    changeset.transform_values do |value|
      if value.is_a?(Array)
        # If the attribute is an array, display it as a comma-separated list
        value.join(', ')
      else
        value
      end
    end
  end
end
