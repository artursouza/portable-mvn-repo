# POC for Blessed Maven Repo

In this POC, we use Maven and Snyk to showcase how to create a blessed repo that can be reused across projects.

## Pre-requisites

* Java SDK
* Maven
* Snyk account

## Files

### Dockerfile

Defines a Docker image containing a Maven repo with artifacts defined by the dependency tree generated for `pom.xml`.

### pom.xml

Declares all high-level dependencies to be consumed later.

### nginx.conf

Configuration for the HTTP service exposing the Maven repo endpoint. Listens to port 80 by default.

### test-project-good

Example of a project that can consumes the dependencies from the local repo gracefully.

### test-project-bad

Example of a project that can consumes a non-approved dependency, i.e. not present in the local repo.

#### test-project-good(bad)/pom.xml

Example of a pom.xml that uses the local repo as the only source to download dependencies. One of the dependencies differ in

## Run it

### Step 1: Build the blessed repo

```sh
export SNYK_API_TOKEN=(your token goes here)
docker build --build-arg SNYK_API_TOKEN -t snyked-maven-repo .
```

### Step 2: Run the repo service locally

```sh
docker run -p 8080:80 --rm snyked-maven-repo:latest
```

### Step 3: Test the good example

```
rm -rf ~/.m2; rm -rf test-project-good/target; mvn install -f test-project-good/pom.xml
```

Notice that all downloaded files are coming from http://localhost:8080

### Step 4: Test the bad examples

```
rm -rf ~/.m2; rm -rf test-project-bad/target; mvn install -f test-project-bad/pom.xml
rm -rf ~/.m2; rm -rf test-project-bad2/target; mvn install -f test-project-bad2/pom.xml
```

Notice that all downloaded files are coming from http://localhost:8080 and there is an error due to an unresolved dependency.

## The Good

* Creating a blessed repo is possible and it can be deployed in organizations that have tight control on dependency management or restrict network access in some environments.

## The Bad

* This solution does not work if developer has non-blessed dependencies cached locally. For this reason, we delete the local Maven cache in the commands above. This limits how much proxying the download of the dependencies can be valuable to developers *but* it can still be useful in a CI/CD pipeline where the cache is always clean in the beginning.

## The Ugly

* This time-boxed solution does not allow multiple versions of the same artifact to be available in the repo. On the other hand, this can be resolved by enhancing this POC:
  * Developer declares dependencies in a separate file: `dependencies.txt` or something.
  * Dockerfile has instructions to read that file and generate one `pom.xml` per dependency and resolve it. Cache is maintained between runs, so all the dependencies are cached.
