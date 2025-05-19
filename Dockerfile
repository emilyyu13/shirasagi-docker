FROM ruby:3.2.3

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    imagemagick \
    git \
    mecab \
    libmecab-dev \
    mecab-ipadic-utf8 \
    ruby-mecab \
    && rm -rf /var/lib/apt/lists/*

# Install yarn
RUN npm install -g yarn

COPY ./shirasagi /app

WORKDIR /app

# Create a symlink for MeCab
RUN ln -s /usr/lib/x86_64-linux-gnu/libmecab.so.2 /usr/lib/libmecab.so

# Create a wrapper for MeCab
RUN echo 'module MeCab; end' > /app/lib/mecab_wrapper.rb

# Patch the public filter to handle missing pages gracefully
RUN sed -i 's/raise SS::NotFoundError/Rails.logger.debug("Page not found, but continuing")/g' /app/app/controllers/concerns/cms/public_filter.rb

# Install dependencies
RUN bundle install && \
    yarn install

RUN yarn add openlayers

RUN mkdir -p vendor/assets/javascripts/openlayers && \
    cp node_modules/openlayers/dist/ol.js vendor/assets/javascripts/openlayers/ol.js

RUN mkdir -p vendor/assets/javascripts/gridster && \
    curl -L https://raw.githubusercontent.com/ducksboard/gridster.js/master/dist/jquery.gridster.min.js \
    -o vendor/assets/javascripts/gridster/jquery.gridster.min.js

RUN mkdir -p vendor/assets/javascripts && \
    curl -L https://raw.githubusercontent.com/lou/multi-select/master/js/jquery.multi-select.js \
    -o vendor/assets/javascripts/jquery.multi-select.js

RUN mkdir -p vendor/assets/stylesheets/gridster && \
    curl -L https://raw.githubusercontent.com/ducksboard/gridster.js/master/dist/jquery.gridster.min.css \
    -o vendor/assets/stylesheets/gridster/jquery.gridster.min.css

RUN mkdir -p vendor/assets/stylesheets && \
    curl -L https://raw.githubusercontent.com/lou/multi-select/master/css/multi-select.css \
    -o vendor/assets/stylesheets/jquery.multi-select.css

# Precompile assets
RUN bundle exec rake assets:precompile RAILS_ENV=development

COPY ./shirasagi/start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Container startup command in development mode
ENV RAILS_ENV=development
CMD ["/app/start.sh"]
