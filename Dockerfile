# =============================================================================
# Target: base
#

FROM ruby:2.7.1-alpine AS base

# This is just metadata and doesn't actually "expose" this port. Rather, it
# tells other tools (e.g. Traefik) what port the service in this image is
# expected to listen on.
#
# @see https://docs.docker.com/engine/reference/builder/#expose
EXPOSE 3000

# =============================================================================
# Labels

LABEL edu.berkeley.lib.build-number="${BUILD_NUMBER}"
LABEL edu.berkeley.lib.build-url="${BUILD_URL}"
LABEL edu.berkeley.lib.git-commit="${GIT_COMMIT}"
LABEL edu.berkeley.lib.git-repo="${GIT_URL}"
LABEL edu.berkeley.lib.project-tier="4-hour response during business hours"
LABEL edu.berkeley.lib.project-description="Audio/video player"

# =============================================================================
# Global configuration

ENV APP_USER=avplayer
ENV APP_UID=40040

# Create the application user/group and installation directory
RUN addgroup -S -g $APP_UID $APP_USER && \
    adduser -S -u $APP_UID -G $APP_USER $APP_USER && \
    mkdir -p /opt/app /var/opt/app && \
    chown -R $APP_USER:$APP_USER /opt/app /var/opt/app /usr/local/bundle

# Install packages common to dev and prod.
RUN apk --no-cache --update upgrade && \
    apk --no-cache add \
        bash \
        ca-certificates \
        git \
        libc6-compat \
        nodejs \
        openssl \
        tzdata \
        xz-libs \
        yarn \
    && rm -rf /var/cache/apk/*

# All subsequent commands are executed relative to this directory.
WORKDIR /opt/app

# =============================================================================
# Target: development
#

FROM base AS development

# Install system packages needed to build gems with C extensions.
RUN apk --update --no-cache add \
        build-base \
        coreutils \
        git \
    && rm -rf /var/cache/apk/*

USER $APP_USER

# Workaround for certificate issue pulling av_core gem from git.lib.berkeley.edu
ENV GIT_SSL_NO_VERIFY=1

# The base image ships bundler 1.17.2, but on macOS, Ruby 2.6.4 comes with
# bundler 1.17.3 as a default gem, and there's no good way to downgrade.
# So let's upgrade!
RUN gem install bundler -v 2.1.4

# Install gems. We do this first in order to maximize cache reuse, and we
# do it only in the development image in order to minimize the size of the
# final production image (which just copies the build products from dev)
COPY --chown=$APP_USER Gemfile* ./
RUN bundle install --jobs=$(nproc) --path=/usr/local/bundle

# Copy the rest of the codebase.
COPY --chown=$APP_USER . .

# Show the home page
ENV LIT_SHOW_HOMEPAGE=1

# Extend the path to include our binstubs. Note that this must be done after
# we've installed the application (and these scripts) otherwise you'll run
# into weird path-related issues.
ENV PATH "/opt/app/bin:$PATH"
ENV RAILS_LOG_TO_STDOUT=yes

CMD ["rails", "server"]

# =============================================================================
# Target: production
#

FROM base AS production

# Run as the app user to minimize risk to the host.
USER $APP_USER

# Copy the built codebase from the dev stage
COPY --from=development --chown=$APP_USER /opt/app /opt/app
COPY --from=development --chown=$APP_USER /usr/local/bundle /usr/local/bundle

ENV PATH "/opt/app/bin:$PATH"

# Sanity-check gems
RUN bundle config set deployment 'true'
RUN bundle install --local

# Run the production stage in production mode.
ENV RACK_ENV=production
ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=yes

# Pre-compile assets so we don't have to do it in production.
RUN rails assets:precompile

CMD ["rails", "server"]
