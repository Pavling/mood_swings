MoodSwings::Application.routes.draw do
  resources :metrics


  devise_for :users

end
