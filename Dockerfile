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

# 安装 yarn
RUN npm install -g yarn

WORKDIR /app

COPY ./shirasagi /app

# RUN bundle config set --local path 'vendor/bundle' && \
#     bundle install
RUN bundle install && \
    yarn install

# CMD ["bash", "-c", "bin/dev"]
# 容器启动后默认执行
CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0", "-p", "3000"]
