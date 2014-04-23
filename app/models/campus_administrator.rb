class CampusAdministrator < ActiveRecord::Base
  belongs_to :administrator, class_name: 'User'
  belongs_to :campus
end
