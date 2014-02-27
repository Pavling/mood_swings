MoodSwings::Application.routes.draw do
  resources :answer_sets
  resources :metrics


  devise_for :users

end
