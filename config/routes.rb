ActionController::Routing::Routes.draw do |map|
  map.resources :incoming_mails
#  map.resources :incoming_mails, :path_prefix => '/projects/:project_id'
end
