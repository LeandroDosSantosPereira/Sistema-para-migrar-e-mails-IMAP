Rails.application.routes.draw do
  # get '/', to: 'home#index' 
  get 'imap', to: 'home#imap', as: :imap 
  # post 'send_imap', to: 'home#send_imap' 
  post 'imap', to: 'home#send_imap' 
 # You can have the root of your site routed with "root" 
  # root 'home#index' 
  root 'home#imap' 
end
