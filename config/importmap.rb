# Pin npm packages by running ./bin/importmap

pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin 'marked' # @13.0.2
pin 'dompurify' # @3.1.6
pin 'dropzone' # @6.0.0
pin 'just-extend' # @5.1.1
pin '@rails/activestorage', to: '@rails--activestorage.js' # @7.1.3
pin_all_from 'app/javascript/helpers', under: 'helpers'
