# get the libraries
library(rmongodb)
library(rCharts)

# connect to localhost mongodb
mongo <- mongo.create()

# create map object
parksMap <- Leaflet$new()

# prepare the fields
fields = mongo.bson.buffer.create()
mongo.bson.buffer.append(fields, "lat", 1L)
mongo.bson.buffer.append(fields, "lon", 1L)
mongo.bson.buffer.append(fields, "Name", 1L)
mongo.bson.buffer.append(fields, "Courts", 1L)
mongo.bson.buffer.append(fields, "Phone", 1L)
fields = mongo.bson.from.buffer(fields)

# only get parks that have location
queryCriteria <- mongo.bson.from.JSON('{"lat": { "$gt": 0 } }')

# set the database and collection
db_collection = "tennis.courts"

# run the query
cursor <- mongo.find(mongo, db_collection, queryCriteria, 
                            fields=fields, limit=100L)

# loop through results and create marker with popup
while (mongo.cursor.next(cursor)) {

  # iterate and grab the next record
  park = mongo.bson.to.list(mongo.cursor.value(cursor))
  
  # collect park details for popup
  parkLat = park$lat
  parkLon = park$lon
  parkName = paste0("<b>", park$Name, "</b>")
  parkTennisCourts = paste0("Tennis Courts: ", park$Courts)
  parkPhone = park$Phone
  parkPopupDetails = paste0("<p>", parkName, "<br />", 
                            parkCourts, "<br/>", parkPhone, "</p>")
  
  # create marker
  parksMap$marker(c(parkLat, parkLon), bindPopup = parkPopupDetails)
}

# settings for the map
parksMap$tileLayer(provider = 'Stamen.TonerLite')
parksMap$set(width = 1200, height = 600)

# set (lat, long) and zoom level
parksMap$setView(c(40.73029, -73.99076), 10)

# save to HTML
parksMap$save('parks-tennis.html', cdn = TRUE)

# disconnect from mongodb
mongo.disconnect(mongo)
mongo.destroy(mongo)
