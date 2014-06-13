MoodSwings::Application.routes.draw do
  devise_for :users, controllers: { registrations: "registrations", invitations: "invitations" }

  resources :answer_sets, only: [:index, :create], path: :swingings
  resources :campuses
  resources :cohorts
  resources :metrics
  resources :users, only: [:index, :show, :edit, :update]

  root to: 'answer_sets#index', constraints: lambda { |request| request.env['warden'] && request.env['warden'].user && request.env['warden'].user.admin? }
  root to: 'answer_sets#index', constraints: lambda { |request| request.env['warden'] && request.env['warden'].user && request.env['warden'].user.cohort_admin? && request.env['warden'].user.cohort.blank? }
  root to: 'home#index'

end
