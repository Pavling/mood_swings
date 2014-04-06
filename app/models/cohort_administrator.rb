class CohortAdministrator < ActiveRecord::Base
  belongs_to :administrator, class_name: 'User'
  belongs_to :cohort
  # attr_accessible :title, :body
end
