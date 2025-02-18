##  Run the Application

Open the terminal/command prompt and run:

```console
docker pull neta520/my-flask-app:latest
docker run -d -p 5000:5000 --name flask-app neta520/my-flask-app:latest
```
 
Open the terminal/command prompt from the root directory of the project and run:
```console
cd client
flutter pub get
flutter run -d chrome
