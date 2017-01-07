# table-tennis-rating-app

Genius!


## TODO

- [ ] Add all the infrastructure code - and make a script to automatically generate the notebook.
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
