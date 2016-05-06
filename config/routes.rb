Rails.application.routes.draw do

  resources :deliverers
  devise_for :users
  root 'check_ins#index'

  resources :check_ins do
    collection do
      get 'import_csv'
      post 'process_csv'
      get 'delete_all'
      post 'confirm_delete_all'
      get 'show_on_map'
      post 'refresh_map_view'
    end
  end
  resources :sections do
    collection do
      get 'import_csv'
      post 'process_csv'
      get 'delete_all'
      post 'confirm_delete_all'
    end
    member do
      get 'show_per_time_slot'
      post 'refresh_per_time_slot'
      get 'show_per_day_of_week'
      post 'refresh_per_day_of_week'
      get 'show_avg_per_time_slot'
      post 'refresh_avg_per_time_slot'
      get 'show_avg_per_day_of_week'
      post 'refresh_avg_per_day_of_week'
      get 'show_check_ins_time_series'
      post 'refresh_check_ins_time_series'
      get 'download_csv_reports'
    end
  end
  resources :section_configurations do
    collection do
      get 'import_csv'
      post 'process_csv'
      get 'delete_all'
      post 'confirm_delete_all'
    end
  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

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
