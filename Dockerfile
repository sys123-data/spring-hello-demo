# create multistage dockerfile
############################################################################################################
# stage 1
############################################################################################################
# build the app
# create gradle wrapper
FROM eclipse-temurin:17-jdk-alpine-3.21 as gradle8jdk17
# RUN apk add --no-cache openjdk17
# Set Gradle version (for example, 8.0)
ENV GRADLE_VERSION=8.12.1
# Install dependencies: curl and bash (for Gradle installation)
RUN apk add --no-cache curl bash
# Download and install Gradle
RUN curl -fsSL "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" -o gradle.zip\
    && unzip gradle.zip -d /opt/
RUN rm gradle.zip \
    && ln -s /opt/gradle-${GRADLE_VERSION} /opt/gradle \
    && ln -s /opt/gradle/bin/gradle /usr/local/bin/gradle
# Set environment variables for Gradle
ENV GRADLE_HOME=/opt/gradle
ENV PATH=$PATH:$GRADLE_HOME/bin
# Verify Gradle version
RUN gradle --version
# when running in detach mode this command will keep container up
# CMD ["tail", "-f", "/dev/null"]
# docker image build -t gradle:8.12.1 .
# docker container run -d --name gradle gradle:8.12.1
# connect to gradle container and run gradle --version
# docker container exec -it gradle gradle --version

############################################################################################################
# stage 2
############################################################################################################
# test spring-boot app
FROM gradle8jdk17 as build
# copy the app
COPY . /app
WORKDIR /app
# run the test
RUN gradle test --info  # For more detailed logs
# build the app: no tests are run because we have already run the tests previously
RUN gradle build -x test
# ############################################################################################################
# # stage 3
# ############################################################################################################
FROM eclipse-temurin:17-jre-alpine-3.21
# set the working directory | now we do not need to use /app because we are already in it
WORKDIR /app
# copy the app
COPY --from=build /app/build/libs/*.jar app.jar
# create user and group
RUN addgroup -S springG && adduser -S springU -G springG
# change the owner of the app
RUN chown springU:springG app.jar
# minim permissions for the user to run the app is read and execute
RUN chmod 500 app.jar
# switch to the user
USER springU
# expose the port
EXPOSE 8080
# limit min and max memory usage
ENTRYPOINT ["java", "-Xms256m", "-Xmx512m", "-jar", "app.jar"]