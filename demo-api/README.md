# Firefly

This is a Dockerized Flask API that simulates the status of a rocket on its journey to the moon. The rocket can be in one of four states: "On Earth", "In transit", "On the moon", or "LOS (loss of signal)". The API returns a random status along with additional information based on the state.

## Project Structure

```
rocket_status_api/
│
├── app/
│   ├── __init__.py
│   ├── routes.py
│   └── status.py
├── Dockerfile
├── requirements.txt
└── app.py
```

## Getting Started

### Prerequisites

Ensure you have the following installed on your local machine:

- Docker
- Docker Compose (optional, if you plan to use Docker Compose)

### Setup and Build

1. **Clone the repository**:

    ```sh
    git clone <repository_url>
    cd rocket_status_api
    ```

2. **Build the Docker image**:

    ```sh
    docker build -t rocket_status_api .
    ```

### Running the Docker Container

To run the Docker container and expose the API on port 5001:

```sh
docker run -d -p 5001:5000 rocket_status_api
```

### Accessing the API

Once the container is running, you can access the API at:

```
http://localhost:5001/status
```

To check the status of the rocket, you can use a web browser or a tool like `curl`:

```sh
curl http://localhost:5001/status
```

### Stopping the Container

To stop the running container, you can use the `docker ps` command to find the container ID and then `docker stop` to stop it:

1. **List all running containers**:

    ```sh
    docker ps
    ```

2. **Stop the container**:

    ```sh
    docker stop <container_id>
    ```

### Example Responses

The API returns a JSON response with the status of the rocket. Example responses include:

- **On Earth**:

    ```json
    {
        "state": "On Earth"
    }
    ```

- **In transit**:

    ```json
    {
        "state": "In transit",
        "distance_from_earth": "150000 km",
        "distance_to_moon": "50000 km",
        "speed": "20000 km/h"
    }
    ```

- **On the moon**:

    ```json
    {
        "state": "On the moon",
        "nearest_crater": "Tycho",
        "landing_time": "2023-06-01 12:34:56"
    }
    ```

- **LOS (loss of signal)**:

    ```json
    {
        "state": "LOS"
    }
    ```

## Development

### Running Locally Without Docker

To run the Flask application locally without Docker, follow these steps:

1. **Create a virtual environment** (optional but recommended):

    ```sh
    python -m venv venv
    source venv/bin/activate  # On Windows use `venv\Scripts\activate`
    ```

2. **Install dependencies**:

    ```sh
    pip install -r requirements.txt
    ```

3. **Run the Flask application**:

    ```sh
    python app.py
    ```

The application will be accessible at `http://localhost:5000/status`.