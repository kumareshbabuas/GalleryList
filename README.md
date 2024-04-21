# Image Grid iOS Project

This iOS project implements a 3-column square image grid that displays images fetched from a provided API URL. The project includes features such as asynchronous image loading, caching mechanism for efficient retrieval, error handling for network errors and image loading failures, and the ability to scroll through at least 100 images.

## Tasks

### Image Grid

Show a 3-column square image grid with center-cropped images.

### Image Loading

Implement asynchronous image loading using the provided URL. Construct image URLs using the fields of the thumbnail object in the API response with the formula: `imageURL = domain + "/" + basePath + "/0/" + key`.

### Display

User should be able to scroll through at least 100 images in the grid.

### Caching

Develop a caching mechanism to store images retrieved from the API in both memory and disk cache for efficient retrieval.

### Error Handling

Handle network errors and image loading failures gracefully, providing informative error messages or placeholders for failed image loads.

## Implementation

This project is implemented in Swift using native iOS technologies.

## Usage

To run the project:
1. Clone the repository.
2. Open the Xcode project file. (Xcode latest version 15.3)
3. Build and run the project on a simulator.
4. Explore the image grid and scroll through the images.
