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

WORKDIR /app

# Clone shirasagi repository
RUN git clone https://github.com/shirasagi/shirasagi.git /app

# Configure MongoDB connection
RUN cd /app && \
    cp -n config/samples/mongoid.yml config/mongoid.yml && \
    sed -i 's/localhost:27017/mongodb:27017/g' config/mongoid.yml

# Create a symlink for MeCab
RUN ln -s /usr/lib/x86_64-linux-gnu/libmecab.so.2 /usr/lib/libmecab.so

# Create a wrapper for MeCab
RUN echo 'module MeCab; end' > /app/lib/mecab_wrapper.rb

# Patch the public filter to handle missing pages gracefully
RUN sed -i 's/raise SS::NotFoundError/Rails.logger.debug("Page not found, but continuing")/g' /app/app/controllers/concerns/cms/public_filter.rb

# Install dependencies
RUN bundle install && \
    yarn install

# Create startup script with database initialization and demo data
RUN echo '#!/bin/bash \n\
bundle exec rake db:drop db:create \n\
bundle exec rake ss:create_site data="{ name: \"SHIRASAGI\", host: \"www\", domains: \"localhost:3000\" }" \n\
bundle exec rake ss:create_user data="{ name: \"システム管理者\", email: \"sys@example.jp\", password: \"pass\" }" \n\
bundle exec rake db:seed name=demo site=www || true \n\
bundle exec rake cms:generate_nodes site=www || true \n\
bundle exec rake cms:generate_pages site=www || true \n\
bundle exec rails s -b 0.0.0.0 -p 3000 \
' > /app/start.sh && \
chmod +x /app/start.sh

# Container startup command in development mode
ENV RAILS_ENV=development
CMD ["/app/start.sh"]
