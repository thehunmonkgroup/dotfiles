# Alias to trigger a local site rebuild.
# With incremental build disabled.
alias jkb="bundle exec jekyll clean && bundle exec jekyll server --port 4001 -w --livereload --config _config.yml,_config.dev.yml"
# With incremental build enabled.
alias jkbi="bundle exec jekyll clean && bundle exec jekyll server --port 4001 -w -I --livereload --config _config.yml,_config.dev.yml"
