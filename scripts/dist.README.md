# odex.viewer

This archive contains a self-contained, directly executable Windows 
distribution package of the odex.viewer - a web-based viewer for exploring 
automotive diagnostic data description files based on the file format 
described by ISO 22901.
It consists of a frontend and a backend server. The backend provides the 
underlying data via a RESTful HTTP API, whilst the frontend visualizes said 
data within a web browser using web technologies.

## Preparation

Unzip the content of the archive to a folder of your choice, e.g., 
`C:\odex.viewer`.
The chosen target directory is named `ODEX_VIEWER_DIR` in the following.

## Usage

Open the `%ODEX_VIEWER_DIR%` folder and double-click on the 
`start_odex-viewer.bat` file.

This will start the odex.viewer backend server on `http://localhost:8080` and 
after waiting for 10 seconds for the backend to startup, it automatically 
opens a browser and loads the odex.viewer frontend.

The startup time of the odex.viewer backend might vary depending on your 
hardware setup, therefore it might be the case that the browser is already 
opened while the backend is not fully started yet.

On the landing page you can then select a PDX file from your file system and 
upload it via the respective button.
As soon as the data is processed by the backend, your are automatically 
forwarded to the overview page of the uploaded ODX data.
From there you can explore the data and navigate through the different 
elements and layers via the odex.viewer frontend.

## Disclaimer

This distribution package is created for testing purposes only.
For further imformation, checkout the open source distribution available on 
GitHub: <https://github.com/mercedes-benz/odex.viewer>

The odex.viewer is currently work-in-progress and therefore does not support 
all elements or relations between elements defined within the ODX standard yet.
In addition, the way how information is presented or navigation between 
different layers is realized, may not fit to all use cases or might lack 
certain aspects.

Therefore, any feedback or contributions to odex.viewer are highly welcome.
