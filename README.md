# table-tennis-rating-app

Genius!

This project also serves as a nice template for integrating sbt projects (e.g. Intellij) with Zeppelin. That is 

 - provides a neat mechanism for writing code in Intellij and calling it from Zeppelin.
 - provides scripts to build and package & release the jar, notebooks and docker image.
 - provides an uber-test-harness that allows you to include the running of notebooks (and their success) in your tests.
 - provides the start of a crufty Scala wrapper for the Zeppelin Rest API

## TODO

- [ ] make a script to automatically generate notebooks.
- [ ] Add in Login
- [ ] Come up with a state solution (so can just overwrite the docker container).  Could write a script to extract state, overwrite container, write state.  Might be easier when Zeppelin has a file upload & download API.
- [ ] timestamps as datetime for easier human reading
- [ ] Alter algorithm to calculate rating adjustment on a day-by-day (configurable time interval) basis (rather than after every game).
- [ ] Modify rating code so it isn't step wise (so it's a continuous function), thought try to preserve the rough shape. Make it configurable too
- [ ] Progress plots
- [ ] Other player analytics (like opponent diversity, ratings over time)
- [ ] Buttons for adding players
- [ ] Recommendations for who to play (based on not played in a while, and level)
- [ ] much later, v999, Queueing system with notifications (hipchat / slack integration)

## Initial Setup - Project Bootstrap

This README currently assumes you use a mac. If you are familiar with Docker and linux then you should easily be able to
adjust for linux.

### Required Software

You need Docker and SBT installed.  The method to install Docker is changing day by day, so please Google.
To install SBT it should just be `brew install sbt` (for mac).

You also need `jq`, `brew install jq`.

Following instructions may differ with newer installs of Docker.

## Docker Issues

Docker has billions of issues, most weird behaviour can be fixed with:

```
docker-machine restart default && eval "$(docker-machine env default)"
```

## Zeppelin

The URL will be:

```
eval "$(docker-machine env default)"
echo $DOCKER_HOST | cut -c 7- | tr ':' ' ' | awk '{print $1 ":8080"}'
```

## Disk space issues with docker

Try `docker-machine rm default` then rerun the docker-machine create command above. This will be very slow!

## To Run Locally

Use `./bin/run-local-mode.sh`. This will block your shell. You can stop in another shell with `./bin/stop.sh`.

To "ssh" into the running docker container (useful for debugging) use `./bin/ssh.sh`

## To Run Tests

To run the Integration Tests run `./bin/it-tests.sh` (at the time of writing none yet exist)

To run the unit tests `sbt test`.

To run the E2E uber notebook tests run `./bin/notebooks-it-tests.sh`

## To Build

To build the jar run `sbt assembly`. To build the big Docker tar ball use `./bin/build.sh`. 

## To get inside (ssh) the running docker image

Just run `ssh.sh`

## To Rename Project

Change `ttra` in every file found by

```
grep -R ttra * | grep -i project | grep -v Binary | grep -v target
```

TODO write a script to auto-replace


