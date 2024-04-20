# NewsClips
Tasks:
Image Grid: Show a 3-column square image grid. The images should be center- cropped.
Image Loading:
Implement asynchronous image loading using this url.
In the response of above API you will get thumbnail object in each array element. Use following formula to construct Image URL using fields of thumbnail object
1 imageURL = domain + "/" + basePath + "/0/" + key
Display: User should be able to scroll through at least 100 images.
Caching: Develop a caching mechanism to store images retrieved from the API in
both memory and disk cache for efficient retrieval.
Error Handling: Handle network errors and image loading failures gracefully when fetching images from the API, providing informative error messages or placeholders for failed image loads.
Implementation to be done in Swift using Native technology.
