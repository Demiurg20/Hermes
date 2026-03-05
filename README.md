# Project Planning

## Hermes – Car Sharing Mobile Application

### Project Overview

Hermes is a mobile car-sharing application developed as a coursework project by a team of four students. The purpose of the application is to provide users with a convenient platform for renting vehicles through a mobile interface. The system allows users to register, browse available cars, select pickup locations, book vehicles, and manage their rental sessions.

The application is built using Flutter for the mobile frontend and Java for the backend server, with PostgreSQL used as the main database for storing user, vehicle, and rental information. Communication between the mobile application and the backend is performed through REST API endpoints.

The Hermes system is designed as a functional prototype demonstrating the core features of modern car-sharing platforms. Although it is developed primarily for academic purposes, the architecture and functionality are designed in a way that could support real-world deployment.

The project development timeline spans ten weeks and involves multiple development stages including analysis, design, implementation, testing, and documentation.

---

# Stage 1 — Project Initialization

### Objective

Establish the initial development environment and project structure.

### Activities

* Creating an empty Flutter project
* Setting up the Java backend environment
* Configuring PostgreSQL database
* Creating the GitHub repository
* Defining project folder structure
* Installing necessary development tools

### Description

At the beginning of the project, the development team prepares the technical infrastructure required for development. The Flutter mobile application project is created and organized into a structured directory layout containing features, core components, and models.

At the same time, the backend system is initialized using Java. Database configuration is completed using PostgreSQL to allow structured storage of user information, vehicle data, and rental transactions.

GitHub is used as the main version control platform, allowing the team to collaborate efficiently and maintain a history of development progress.

### Deliverables

* Initialized Flutter project
* Backend server setup
* GitHub repository
* Basic project structure

---

# Stage 2 — Research and Requirements Analysis

### Objective

Analyze existing car-sharing applications and define the system requirements.

### Activities

* Studying at least five existing car-sharing applications
* Identifying common functionality
* Defining user needs
* Determining functional and non-functional requirements

### Description

During this stage, the development team analyzes existing car-sharing platforms such as Zipcar, Getaround, and other similar services. The goal is to understand the functionality and structure of modern car-sharing systems.

The team identifies the key features that must be included in the Hermes application. These include user authentication, car browsing, vehicle booking, profile management, and location selection.

Non-functional requirements are also defined, including system usability, security of user data, and system performance.

### Deliverables

* Requirements specification
* List of system features
* Functional requirements documentation

---

# Stage 3 — System Design

### Objective

Design the system architecture and data structure of the application.

### Activities

* Designing system architecture
* Creating system flowcharts
* Designing database schema
* Defining API endpoints
* Planning system communication

### Description

At this stage, the system architecture of Hermes is designed. The application follows a client-server architecture where the Flutter mobile application communicates with the backend server through REST API requests.

The database structure is designed to store information about users, vehicles, bookings, and locations. System flowcharts are created to illustrate the main processes of the application such as user authentication, vehicle selection, and the booking process.
[3/4/2026 8:08 PM] iqoshb: API endpoints are also defined to allow communication between the frontend and backend components.

### Deliverables

* System architecture diagram
* Database schema
* Flowchart diagrams

---

# Stage 4 — UI/UX Design

### Objective

Design the visual interface and user interaction of the application.

### Activities

* Designing UI screens in Figma
* Creating navigation structure
* Preparing images, icons, and other assets
* Designing user flow between screens

### Description

The visual design of the Hermes application is created using Figma. The design includes screens for login, registration, home page, vehicle selection, and profile editing.

The goal is to create a clean and intuitive interface that allows users to navigate the application easily. Visual elements such as icons, vehicle images, and interface components are prepared during this stage.

User navigation is also planned to ensure a smooth transition between different application screens.

### Deliverables

* Figma design prototype
* Application UI assets
* Navigation structure

---

# Stage 5 — Backend Development

### Objective

Develop the server-side logic and database integration.

### Activities

* Implementing authentication using JWT
* Implementing vehicle inventory system
* Creating booking logic
* Implementing car availability state
* Implementing penalty and rental rules
* Implementing image upload for driver verification

### Description

The backend of the Hermes application is developed using Java. It provides REST API endpoints that allow the mobile application to perform operations such as user login, retrieving available cars, and creating rental bookings.

The backend also manages vehicle availability states, ensuring that a vehicle cannot be rented by multiple users simultaneously.

Additional features such as rental penalties and timer-based rental duration tracking are implemented to simulate realistic car-sharing logic.

### Deliverables

* Working backend REST API
* Database integration
* Authentication system

---

# Stage 6 — Frontend Development

### Objective

Develop the mobile application interface and connect it to the backend.

### Activities

* Implementing login and registration screens
* Developing the home screen
* Implementing vehicle browsing
* Creating profile editing functionality
* Implementing search and filtering features

### Description

The frontend of the Hermes system is developed using Flutter. This stage focuses on translating the UI designs into a functional mobile application.

Users can register, log in, browse available vehicles, search for cars, and view information about available vehicles.

The mobile application communicates with the backend API to retrieve data and perform user actions such as booking a vehicle.

### Deliverables

* Functional Flutter mobile application
* API communication implementation

---

# Stage 7 — Booking System Implementation

### Objective

Implement the core rental functionality of the application.

### Activities

* Creating vehicle inventory
* Implementing car availability states
* Implementing booking process
* Implementing rental timer
* Calculating rental price
* Managing rental lifecycle

### Description

The booking system allows users to select a car and rent it for a specific period of time. Each car in the system has a state that indicates whether it is available or currently rented.

When a booking is made, the system updates the state of the vehicle and begins tracking the rental duration using a timer.

The rental cost is calculated based on factors such as vehicle type and rental duration.

### Deliverables

* Functional booking system
* Rental tracking logic
* Pricing calculation system

---

# Stage 8 — Integration and Testing

### Objective

Integrate frontend and backend systems and test application functionality.

### Activities

* Connecting frontend to backend API
* Testing user authentication
* Testing booking process
* Testing vehicle state management
* Fixing bugs and improving stability

### Description
[3/4/2026 8:08 PM] iqoshb: During this stage, the mobile application is connected to the backend system. The development team performs extensive testing to ensure that all features function correctly.

Integration testing verifies that communication between the frontend and backend works properly and that data is stored and retrieved correctly from the database.

### Deliverables

* Fully integrated system
* Tested application prototype

---

# Stage 9 — Documentation

### Objective

Prepare academic documentation for the coursework.

### Activities

* Writing the project report
* Adding system diagrams
* Creating Gantt chart
* Adding screenshots of the application
* Writing technical explanations

### Deliverables

* Complete coursework report

---

# Stage 10 — Final Presentation and Deployment

### Objective

Prepare the project for final demonstration.

### Activities

* Final testing
* Preparing APK build
* Preparing presentation materials
* Demonstrating system functionality

### Deliverables

* Final working prototype
* Project presentation



1. Zipcar is a service where users can rent cars by the hour or by the day. It mainly works in cities and near universities.

2. Turo is a peer-to-peer platform. Car owners can rent their personal vehicles to other people.

3. Getaround allows users to unlock cars using a mobile app. This makes the process faster and more convenient.

4. Share Now (Car2Go) uses a free-floating model. Users can pick up and leave the car anywhere inside a city area.

5. Yandex Drive uses dynamic pricing and real-time tracking to manage cars efficiently.