class ApplicationController < ActionController::Base
  # layout "main"
  before_action :set_paper_trail_whodunnit
  before_action :authenticate_user!, except: [:main]

  def parse_and_format_datetime(datetime_string)
    formatted_datetime = DateTime.strptime(datetime_string, "%m/%d/%Y %H:%M:%S")
    local_datetime = formatted_datetime.in_time_zone("Asia/Jakarta")
    local_datetime.strftime("%Y-%m-%dT%H:%M:%S")
  end

end
