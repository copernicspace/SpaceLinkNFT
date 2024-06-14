//args = [state, distance_from_earth, distance_to_moon, speed, nearest_creater, landing_time]


const apiURL = "http://192.168.74.229:5000/status"

const state = args[0]
const distance_from_earth = args[1]
const distance_to_moon = args[2]
const speed = args[3]
const nearest_crater = args[4]
const landing_time = args[5]



// Making HTTP request to the API
const apiRequest = Functions.makeHttpRequest({
  url: apiURL,
  method: "GET",
  params: {
    state: state,
    "distance_from_earth": distance_from_earth,
    "distance_to_moon": distance_to_moon,
    "speed": speed,
    "nearest_crater": nearest_crater,
    "landing_time": landing_time
  },
})

// Response from the API
const apiResponse = await apiRequest

if (apiResponse.error) {
  console.error(apiResponse.error)
  throw Error("Request failed, try checking the API endpoint")
}

console.log(apiResponse)

const data = apiResponse.data

let result = { state: data.state }

if (data.state === "In transit") {
  result = {
    state: data.state,
    distance_from_earth: data.distance_from_earth,
    distance_to_moon: data.distance_to_moon,
    speed: data.speed,
  }
} else if (data.state === "On the moon") {
  result = {
    state: data.state,
    nearest_crater: data.nearest_crater,
    landing_time: data.landing_time,
  }
}

// Use JSON.stringify() to convert from JSON object to JSON string
// Finally, use the helper Functions.encodeString() to encode from string to bytes
return Functions.encodeString(JSON.stringify(result))

