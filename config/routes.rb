Rails.application.routes.draw do
  resources :domino_messages

  resources :names_entries

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  resources :domino_servers do
    member do
      post "load_names_entry"
    end

  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
  get "session/new"
  post "session/create"
  delete "session/destroy"
  get "session/destroy"
  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root 'home#index'
  
  get 'flot' => 'home#flot'
  get 'morris' => 'home#morris'
  get 'tables' => 'home#tables'
  get 'forms' => 'home#forms'

  get 'panels_wells' => 'home#panels_wells'
  get 'buttons' => 'home#buttons'
  get 'notifications' => 'home#notifications'
  get 'typography' => 'home#typography'
  get 'grid' => 'home#grid'
  get 'blank' => 'home#blank'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
