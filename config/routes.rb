ActionController::Routing::Routes.draw do |map|
  map.resources :incoming_mails, :only => [:index, :show, :destroy]
#  map.resources :incoming_mails, :path_prefix => '/projects/:project_id'
end
