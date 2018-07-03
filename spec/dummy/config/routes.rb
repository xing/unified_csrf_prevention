Rails.application.routes.draw do
  get  '/'        => 'dummy#index'
  post '/'        => 'dummy#update'
  get  '/success' => 'dummy#success'
end
