FROM ruby:2.5.1
EXPOSE 7331

WORKDIR /usr/src/suchgreatheights

COPY Gemfile Gemfile.lock ./
COPY lib ./lib
COPY bin ./bin
COPY config ./config
COPY data ./data

RUN bundle install
RUN mv config/suchgreatheights.yml.sample config/suchgreatheights.yml
RUN sed -i s%/path/to/tile_set%/usr/src/suchgreatheights/data% config/suchgreatheights.yml
RUN mkdir log

CMD ["./bin/server"]
