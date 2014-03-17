MoodSwings::Application.routes.draw do
  resources :answer_sets
  resources :metrics


  devise_for :users

  root to: 'answer_sets#index', constraints: lambda { |request| request.env['warden'] && request.env['warden'].user && request.env['warden'].user.admin? }
  root to: 'home#index'

end
