FROM rails:onbuild

RUN RAILS_ENV=production rake assets:precompile
