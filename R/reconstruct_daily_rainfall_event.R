#' Extract rainfall Events per slide
#'
#' @description This function will extract the rainfall events that happened before a landslide, based on a
#' predefined length ,\code{n}, that can be dry days and still be part of a rainfall event , that can be dry
#' days and still be part of a rainfall event
#'
#' @param d A dataframe with the extracted rainfall for one point or polygon
#' @param n The inverval (in days) a dry period can still be part of a rainfall event
#' @param daily_thresh the minimum daily rainfall to be considered a day of rain
#' @param quiet Show print messages or not
#'
#' @export

reconstruct_daily_rainfall_events = function(d,
                                             n = 1,
                                             daily_thresh = .2,
                                             quiet = TRUE) {
  # start int the first row
  i = 1

  # start with rainfall event 1
  event_counter = 0

  # set the value initially to 0
  d[["event"]] = 0

  # while still in the dataframe
  while (i <= nrow(d)) {
    # get the current precip value
    precip = d[i,]$precip

    # if its below the threshold --> DRY period starts
    if (precip < daily_thresh) {
      # count unknown number of following dry days of this dry episode
      dry_days = 0

      ### DRY LOOP
      # start from the day with rainfall under the threshold
      for (j in i:nrow(d)) {
        # count the consecutive dry days
        if (d[j,]$precip < daily_thresh) {
          dry_days = dry_days + 1

          # when all the days up to the end dont see any rain anymore --> set them also to NA
          if(j == nrow(d)){

            # +1 because we don't want to set the d
            d[((nrow(d)-dry_days)+1):nrow(d), ][["event"]] = NA
          }

        } else{
          # hit a rainy day --> Get out the dry loop, just decide quickly to which event it belongs
          # if the preceeding dry days are smaller than n --> same as last event

          if (dry_days <= n) {
            # set all the days without rainfall but within n to rainfall
            # if its the first event put it to 1
            if (event_counter == 0) {
              event_counter = 1
            }
            d[(j - 1):(j - dry_days),][["event"]] = event_counter
            # set the rainy day to the same event
            d[j,][["event"]] = event_counter
            break # get back to wet peiod

          } else{
            # if the gap was too big --> its a new event
            # set all the days without rainfall and within n to no rainfall
            d[(j - 1):(j - dry_days),][["event"]] = NA
            # set the rainy day to a new rainfall event
            event_counter = event_counter + 1
            d[j,][["event"]] = event_counter
            break # get back to wet period
          }
        }
      }

      if (!quiet) {
        print(paste("Dry period of:", dry_days, "days"))
      }

      # set i to where we stopped in the dry loop
      i = j + 1

    } else{
      # if we initially hit a rainy day, just count on
      # if it was the first day, set the counter to one
      if(i == 1){
        event_counter = event_counter + 1
      }

      d[i,][["event"]] = event_counter
      i = i + 1

    }
  }
  return(d)
}
