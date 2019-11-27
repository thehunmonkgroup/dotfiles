# Alias to trigger a local site rebuild.
# With incremental build disabled.
alias jkb="bundle exec jekyll clean && bundle exec jekyll server -w --livereload --config _config.yml,_config.dev.yml"
# With incremental build enabled.
alias jkbi="bundle exec jekyll clean && bundle exec jekyll server -w -I --livereload --config _config.yml,_config.dev.yml"
