FROM maven:3-openjdk-11 AS build
ARG SNYK_API_TOKEN
ENV SNYK_API_TOKEN=$SNYK_API_TOKEN
# Install Snyk
RUN apt-get update && \
    apt-get install -y nodejs npm && \
    npm install --global snyk && \
    apt-get autoremove -y && \
    apt-get clean
WORKDIR /app
COPY pom.xml .
ENV MAVEN_OPTS="-Dmaven.repo.local=/app/repository"
RUN mvn install

FROM nginx
COPY nginx.conf /etc/nginx/nginx.conf
RUN mkdir /repository
COPY --from=build /app/repository /repository
